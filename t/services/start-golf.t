use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use CodeGolf::Service::StartGolf;

my $storage = get-tmp-storage();

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::StartGolf.new(
          user-id    => 'koorchik',
          session-id => 'aaaa',
          user-role  => 'ADMIN',
          storage    => $storage,
          tester     => get-nodejs-tester,
          |%context
      );

      return $service.run(%params);
}

subtest {
    my %golf = run-my-service({name => 'MyTestGolf'});

    is %golf<name>, 'MyTestGolf', "Golf name is set";
    isa-ok %golf<id>, Int, "Golf id is Int";
    ok %golf<is_active>, "Golf is active";
    ok %golf<started_at>, "Golf has started_at";

}, "Positive: should return new golf";


subtest {
    throws-like { run-my-service({}) },
        CodeGolf::Service::X::ValidationError,
        errors => {name => 'REQUIRED'};
}, "Negative: should require name";


subtest {
    throws-like { run-my-service({}, { user-role => 'USER' }) },
        CodeGolf::Service::X::NotEnoughPermissions;
}, "Negative: USER not allowed to call use service";

done-testing;
