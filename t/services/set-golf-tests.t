use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use Test::CodeGolf::Factory;

use CodeGolf::Service::SetGolfTests;

my $factory = Test::CodeGolf::Factory.new();
$factory.setup-golf();

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::SetGolfTests.new(
          user-id     => 'koorchik',
          session-id  => 'aaaa',
          user-role   => 'ADMIN',
          storage     => $factory.storage,
          notificator => get-notificator-mock($factory.storage, my $bot),
          tester      => get-nodejs-tester,
          |%context
      );

      return $service.run(%params);
}

subtest {
    my %golf = run-my-service({url => 'https://raw.githubusercontent.com/koorchik/codegolf-telegram-bot/master/tests.json'});

    # is %golf<name>, 'MyGolfNewName', "Golf name is set";
}, "Positive: should return new golf";


subtest {
    throws-like { run-my-service({}) },
        CodeGolf::Service::X::ValidationError,
        errors => {url => 'REQUIRED'};

    throws-like { run-my-service({url => 'not a url'}) },
            CodeGolf::Service::X::ValidationError,
            errors => {url => 'WRONG_URL'};
}, "Negative: validation-rules";


subtest {
    throws-like { run-my-service({}, { user-role => 'USER' }) },
        CodeGolf::Service::X::NotEnoughPermissions;
}, "Negative: USER not allowed to use this service";

done-testing;
