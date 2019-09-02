use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use CodeGolf::Service::StartGolf;

my $storage = get-tmp-storage();

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::StartGolf.new(
          user-id     => 'koorchik',
          session-id  => 'aaaa',
          user-role   => 'ADMIN',
          storage     => $storage,
          notificator => get-notificator-mock($storage, my $bot),
          tester      => get-nodejs-tester,
          |%context
      );

      return $service.run(%params);
}

subtest {
    my %golf = run-my-service({name => 'MyTestGolf'});

    is %golf<name>, 'MyTestGolf', "Golf name is set";
    isa-ok %golf<id>, Int, "Golf id is Int";
    ok %golf<is-active>, "Golf is active";
    ok %golf<started-at>, "Golf has started-at";

}, "Positive: should return new golf";


subtest {
    throws-like { run-my-service({}) },
        CodeGolf::Service::X::ValidationError,
        errors => {name => 'REQUIRED'};
}, "Negative: should require name";


subtest {
    throws-like { run-my-service({}, { user-role => 'USER' }) },
        CodeGolf::Service::X::NotEnoughPermissions;
}, "Negative: USER not allowed to use this service";

done-testing;
