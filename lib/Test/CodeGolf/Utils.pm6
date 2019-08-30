use File::Temp;
use CodeGolf::Storage;

sub get-tmp-storage is export {
    my ($filename) = tempfile("testdb-******.sqlite3", :!unlink);
    my $storage = CodeGolf::Storage.new(dbpath => $filename);
    $storage.init;

    return $storage;
}
