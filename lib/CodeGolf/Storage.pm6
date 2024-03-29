use DBIish;

class CodeGolf::Storage {
    has $.db-path is required;
    has $!dbh = DBIish.connect("SQLite", :database($!db-path));

    method init() {
      $!dbh.do(q:to/STATEMENT/);
          CREATE TABLE IF NOT EXISTS golfs (
              id          INTEGER PRIMARY KEY,
              name        VARCHAR(255) NOT NULL,
              tests       TEXT NOT NULL DEFAULT '[]',
              is_active   BOOLEAN NOT NULL DEFAULT 0,
              started_at  TEXT NOT NULL DEFAULT '',
              finished_at TEXT NOT NULL DEFAULT ''
          )
      STATEMENT

      $!dbh.do(q:to/STATEMENT/);
          CREATE TABLE IF NOT EXISTS sessions (
              id   INTEGER PRIMARY KEY,
              user TEXT NOT NULL
          )
      STATEMENT

      $!dbh.do(q:to/STATEMENT/);
          CREATE TABLE IF NOT EXISTS results (
              id          INTEGER PRIMARY KEY,
              golf_id     INTEGER NOT NULL,
              user_id     TEXT NOT NULL,
              source_code TEXT NOT NULL,
              code_length INTEGER NOT NULL,
              submited_at TEXT NOT NULL,
              FOREIGN KEY(golf_id) REFERENCES golfs(id)
          )
      STATEMENT


      $!dbh.do(q:to/STATEMENT/);
          CREATE TABLE IF NOT EXISTS settings (
              id          INTEGER PRIMARY KEY,
              type        TEXT NOT NULL,
              key         TEXT NOT NULL,
              value       TEXT NOT NULL
          )
      STATEMENT
    }

    method insert-golf(Str :$name!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            INSERT INTO golfs (name) VALUES ( ? )
        STATEMENT
        $sth.execute($name);

        $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT last_insert_rowid()
        STATEMENT
        $sth.execute();
        return $sth.row()[0];
    }

    method update-golf(Int $id!, %fields!) {
        my $sth = $!dbh.prepare(qq:to/STATEMENT/);
            UPDATE golfs SET {%fields.keys.map({"$_=?"}).join(' AND ')} WHERE id=?
        STATEMENT
        $sth.execute(%fields.values, $id);
    }

    method activate-golf(Int $id!) {
        $!dbh.do(q:to/STATEMENT/);
            UPDATE golfs SET is_active=0
        STATEMENT

        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            UPDATE golfs SET is_active=1,started_at=DATETIME('now') WHERE id=?
        STATEMENT

        $sth.execute($id);
    }

    method find-golf(Int $id!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM golfs WHERE id=?
        STATEMENT

        $sth.execute($id);
        return self!u2d-hash( $sth.row(:hash) );
    }

    method find-active-golf {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM golfs WHERE is_active=1
        STATEMENT

        $sth.execute();
        return self!u2d-hash( $sth.row(:hash) );
    }

    method insert-result(
        Int :$golf-id,
        Str :$user-id,
        Str :$source-code
    ) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            INSERT INTO results (golf_id, user_id, source_code, code_length, submited_at)
            VALUES ( ?, ?, ?, ?, DateTime('now') )
        STATEMENT
        $sth.execute($golf-id, $user-id, $source-code, $source-code.chars);

        $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT last_insert_rowid()
        STATEMENT
        $sth.execute();
        return $sth.row()[0];
    }

    method find-result(Int $id!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM results WHERE id=?
        STATEMENT

        $sth.execute($id);
        return self!u2d-hash( $sth.row(:hash) );
    }

    method find-golf-results(Int $golf-id!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM results WHERE golf_id=?
        STATEMENT

        $sth.execute($golf-id);
        return self!u2d-array-of-hash( $sth.allrows(:array-of-hash) );
    }

    method save-notificator-setting(%settings) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            REPLACE INTO settings (type, key, value)
            VALUES ('NOTIFICATOR', ?, ?)
        STATEMENT

        for %settings.kv -> $k, $v {
            $sth.execute($k, $v);
        }
    }

    method load-notificator-setting() {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM settings WHERE type='NOTIFICATOR'
        STATEMENT

        $sth.execute();
        my @rows = $sth.allrows(:array-of-hash);

        my %settings;
        for @rows -> $row {
            %settings{$row<key>} = $row<value>;
        }

        return %settings;
    }

    method !u2d-hash(%hash) {
        return %hash.kv.map( *.subst('_', '-', :g) => * ).hash;
    }

    method !u2d-array-of-hash(@array) {
        return @array.map({ self!u2d-hash(%^a) });
    }
}
