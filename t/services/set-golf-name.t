use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use Test::CodeGolf::Factory;

use CodeGolf::Service::SetGolfName;

my $factory = Test::CodeGolf::Factory.new();
$factory.setup-golf();

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::SetGolfName.new(
          user-id    => 'koorchik',
          session-id => 'aaaa',
          user-role  => 'ADMIN',
          storage    => $factory.storage,
          tester     => get-nodejs-tester,
          |%context
      );

      return $service.run(%params);
}

subtest {
    my %golf = run-my-service({name => 'MyGolfNewName'});

    is %golf<name>, 'MyGolfNewName', "Golf name is set";
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
