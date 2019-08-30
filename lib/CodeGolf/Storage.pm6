use DBIish;

class CodeGolf::Storage {
    has $.dbpath = 'codegolf-db.sqlite3';
    has $!dbh = DBIish.connect("SQLite", :database($!dbpath));

    method init() {
      $!dbh.do(q:to/STATEMENT/);
          CREATE TABLE IF NOT EXISTS golfs (
              id          INTEGER PRIMARY KEY,
              name        VARCHAR(255) NOT NULL,
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
              session_id  INTEGER NOT NULL,
              code_length INTEGER NOT NULL,
              submited_at TEXT NOT NULL,
              FOREIGN KEY(golf_id) REFERENCES golfs(id)
              FOREIGN KEY(session_id) REFERENCES sessions(id)
          )
      STATEMENT
    }

    method insert-golf(Str :$name!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
              INSERT INTO golfs (name)
            VALUES ( ? )
        STATEMENT
        $sth.execute($name);

        $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT last_insert_rowid()
        STATEMENT
        $sth.execute();
        return $sth.row()[0];
    }

    method update-golf(Int $id!, %fields!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            UPDATE golfs SET name=? WHERE id=?
        STATEMENT
        $sth.execute(%fields<name>, $id);
    }

    method activate-golf(Int $id!) {
        $!dbh.do(q:to/STATEMENT/);
            UPDATE golfs SET is_active=0
        STATEMENT

        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            UPDATE golfs SET is_active=1,started_at=DATETIME('now') WHERE id=?
        STATEMENT

        "ACTIVE $id".say;
        $sth.execute($id);
    }

    method find-golf(Int $id!) {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM golfs WHERE id=?
        STATEMENT

        $sth.execute($id);
        return $sth.row(:hash);
    }

    method find-active-golf {
        my $sth = $!dbh.prepare(q:to/STATEMENT/);
            SELECT * FROM golfs WHERE is_active=1
        STATEMENT

        $sth.execute();
        return $sth.row(:hash);
    }

    method save-result( Str :$golf-id, Str :$user-id, Str :$code ) {

    }
}
