use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use Test::CodeGolf::Factory;

use CodeGolf::Service::SubmitResult;

my $factory = Test::CodeGolf::Factory.new();
$factory.setup-golf();

my $bot;

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::SubmitResult.new(
          user-id     => 'koorchik',
          session-id  => 'aaaa',
          user-role   => 'ADMIN',
          storage     => $factory.storage,
          notificator => get-notificator-mock($factory.storage, $bot),
          tester      => get-nodejs-tester,
          |%context
      );

      return $service.run(%params);
}

subtest {
    my %result = run-my-service({source-code => 'console.log(process.argv[2]*2)'});

    is %result<user-id>, 'koorchik', "User ID is set";
    is %result<code-length>, 30, "Code length is computed";
    like %result<source-code>, /process.argv/, "Code length is computed";

    isa-ok %result<id>, Int, "Result ID is Int";
    isa-ok %result<golf-id>, Int, "Golf ID is Int";

    ok %result<submited-at>, "Result has submited-at";
}, "Positive: should return new golf";


subtest {
    run-my-service(
        {source-code => '"SOME EXTRA CODE";console.log(process.argv[2]*2)'},
        {user-id => 'userForNotifTest'}
    );

    like $bot.last-message, rx/"userForNotifTest"/, "Shoud contain name of the user";
    like $bot.last-message, rx/"NEW"/, "Shoud contain 'NEW'";

    run-my-service(
        {source-code => 'console.log(process.argv[2]*2)'},
        {user-id => 'userForNotifTest'}
    );

    like $bot.last-message, rx/"userForNotifTest"/, "Shoud contain name of the user";
    like $bot.last-message, rx/"was"/, "Shoud contain 'was'";
}, "Positive: should notify-changes";


subtest {
    throws-like { run-my-service({source-code => 'console.log(process.argv[2]*3)'}) },
         CodeGolf::Service::X::ValidationError,
         errors => {source-code => 'TESTING_FAILED'};
}, "Negative: wrong output";

subtest {
    throws-like { run-my-service({source-code => 'not a code'}) },
         CodeGolf::Service::X::ValidationError,
        errors => {source-code => 'TESTING_FAILED'};
}, "Negative: syntax error";

subtest {
    my %golf = $factory.storage.find-active-golf;
    $factory.storage.update-golf(%golf<id>, { tests => '[]'});

    throws-like { run-my-service({source-code => 'console.log(process.argv[2]*3)'}) },
         CodeGolf::Service::X::ValidationError,
         errors => {source-code => 'NO_TESTS'};
}, "Negative: wrong output";

done-testing;
