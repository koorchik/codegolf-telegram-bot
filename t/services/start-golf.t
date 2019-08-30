use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use CodeGolf::Service::StartGolf;

my $storage = get-tmp-storage();

sub run-my-service(%params) {
      my $service = CodeGolf::Service::StartGolf.new(
          user-id    => 'koorchik',
          session-id => 'aaaa',
          user-role  => 'ADMIN',
          storage    => $storage
      );

      return $service.run(%params);
}

subtest {
    my %golf = run-my-service({name => 'MyTestGolf'});
    %golf.say;
    is %golf<name>, 'MyTestGolf', "Golf name is set";
    isa-ok %golf<id>, Int, "Golf id is Int";
    ok %golf<is_active>, "Golf is active";
    ok %golf<started_at>, "Golf has started_at";

}, "Positive: CodeGolf::Service::StartGolf";


subtest {
    throws-like { run-my-service({}) },
        CodeGolf::Service::X::ValidationError,
        errors => {name => 'REQUIRED'};
}, "Negative: CodeGolf::Service::StartGolf";

done-testing;
