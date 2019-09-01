use File::Temp;
use CodeGolf::Storage;
use CodeGolf::Tester;

sub get-tmp-storage is export {
    my ($filename) = tempfile("testdb-******.sqlite3", :!unlink);
    my $storage = CodeGolf::Storage.new(dbpath => $filename);
    $storage.init;

    return $storage;
}


sub get-nodejs-tester is export {
    return CodeGolf::Tester.new(docker-image => 'node:12-alpine');
}
