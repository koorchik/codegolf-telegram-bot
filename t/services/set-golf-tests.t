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
    my $tests-url = 'https://raw.githubusercontent.com/koorchik/codegolf-telegram-bot/master/t/fixtures/correct-tests.json';
    my %golf = run-my-service({ url => $tests-url });

    # is %golf<name>, 'MyGolfNewName', "Golf name is set";
}, "Positive: should return new golf";

subtest {
    my $tests-url = 'https://raw.githubusercontent.com/koorchik/codegolf-telegram-bot/master/t/fixtures/tests-wrong-json-structure.json';

    throws-like { run-my-service({url => $tests-url}) },
            X::CodeGolf::Service::ValidationError,
            errors => {url => 'WRONG_JSON_STRUCTURE'};
}, "Negative: Wrong JSON structure";

subtest {
    my $tests-url = 'https://raw.githubusercontent.com/koorchik/codegolf-telegram-bot/master/README.md';

    throws-like { run-my-service({url => $tests-url}) },
            X::CodeGolf::Service::ValidationError,
            errors => {url => 'JSON_PARSING_ERROR'};
}, "Negative: Fetch not JSON";

subtest {
    my $tests-url = 'https://raw.githubusercontent.com/koorchik/codegolf-telegram-bot/master/nofile.json';

    throws-like { run-my-service({url => $tests-url}) },
            X::CodeGolf::Service::ValidationError,
            errors => {url => 'FETCHING_ERROR'};
}, "Negative: 404";

subtest {
    throws-like { run-my-service({}) },
        X::CodeGolf::Service::ValidationError,
        errors => {url => 'REQUIRED'};

    throws-like { run-my-service({url => 'not a url'}) },
            X::CodeGolf::Service::ValidationError,
            errors => {url => 'WRONG_URL'};
}, "Negative: validation-rules";


subtest {
    throws-like { run-my-service({}, { user-role => 'USER' }) },
        X::CodeGolf::Service::NotEnoughPermissions;
}, "Negative: USER not allowed to use this service";

done-testing;
