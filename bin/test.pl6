use lib 'lib';

use CodeGolf::Tester;
use CodeGolf::Storage;

sub MAIN {
    my $tester = CodeGolf::Tester.new(
        docker-image => 'node:12-alpine'
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

    CATCH {
       when CodeGolf::Tester::X {
         "CATCH FAILED".say;
       }
    }
}
