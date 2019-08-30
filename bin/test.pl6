use lib 'lib';

<<<<<<< HEAD
use CodeGolf::Tester;
use CodeGolf::Storage;

sub MAIN {
    my $storage = CodeGolf::Storage.new();
    my $tester = CodeGolf::Tester.new(
        docker-image => 'node:12-alpine'
=======
use CodeGolf::Service::SubmitResult;
use CodeGolf::Storage;

sub MAIN {

    my $storage = CodeGolf::Storage.new();
    $storage.init;

    my $service = CodeGolf::Service::SubmitResult.new(
        user-id    => 'koorchik',
        session-id => 'aaaa',
        user-role  => 'ADMIN',
        storage    => $storage
>>>>>>> 1a169548e868d48f57d59f4a4d46b507a98a38fa
    );

    my @tests = (
        {
            "input"    => "123",
            "expected" => "123\n"
        },
        {
            "input"    => "123",
            "expected" => "123\n"
        },
    );

    say @tests.gist;

    $tester.run-all-tests("console.log(123)", @tests);
    $storage.find-active-golf.say;

    CATCH {
<<<<<<< HEAD
       when CodeGolf::Tester::X {
         "CATCH FAILED".say;
       }
=======
        when CodeGolf::Service::X::Base {
            .message.say
        }
        default {
            .message.say;
            say "Server error happened";
        }
>>>>>>> 1a169548e868d48f57d59f4a4d46b507a98a38fa
    }
}
