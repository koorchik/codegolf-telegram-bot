use lib 'lib';

use Test;
use CodeGolf::Tester;

my $tester = CodeGolf::Tester.new( docker-image => 'node:12-alpine' );
my @tests = (
    { "input" => "123",  "expected" => "246\n" },
    { "input" => "1234", "expected" => "2468\n" }
);

subtest {
    ok $tester.run-all-tests("console.log(process.argv[2]*2)", @tests);
}, "Positive: should pass all tests";

subtest {
    throws-like { $tester.run-all-tests("console.log(process.argv[2]*3)", @tests); },
         CodeGolf::Tester::X,
         input    => '123',
         expected => "246\n",
         got      => "369\n"
}, "Negative: wrong output";

subtest {
    throws-like { $tester.run-all-tests("not a code", @tests); },
         CodeGolf::Tester::X,
         input    => '123',
         expected => "246\n",
         got      => /SyntaxError/
}, "Negative: syntax error";

done-testing;
