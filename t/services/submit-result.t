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
    my %result = run-my-service({source-code => 'console.log(process.argv[2]*2)'});

    is %result<user_id>, 'koorchik', "User ID is set";
    is %result<code_length>, 30, "Code length is computed";

    isa-ok %result<id>, Int, "Result ID is Int";
    isa-ok %result<golf_id>, Int, "Golf ID is Int";

    ok %result<submited_at>, "Result has submited_at";
}, "Positive: should return new golf";


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
