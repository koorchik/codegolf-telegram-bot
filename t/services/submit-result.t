use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use Test::CodeGolf::Factory;

use CodeGolf::Service::SubmitResult;

my $factory = Test::CodeGolf::Factory.new();
$factory.setup-golf();

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::SubmitResult.new(
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
    my %golf = run-my-service({source-code => 'console.log(process.argv[2]*2)'});
    "RESULT {%golf.gist}".say;
}, "Positive: should return new golf";

#
# subtest {
#     throws-like { run-my-service({}) },
#         CodeGolf::Service::X::ValidationError,
#         errors => {name => 'REQUIRED'};
# }, "Negative: should require name";
#
#
# subtest {
#     throws-like { run-my-service({}, { user-role => 'USER' }) },
#         CodeGolf::Service::X::NotEnoughPermissions;
# }, "Negative: USER not allowed to call use service";

done-testing;
