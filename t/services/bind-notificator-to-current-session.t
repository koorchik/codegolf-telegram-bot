use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use CodeGolf::Service::BindNotificatorToCurrentSession;

my $storage = get-tmp-storage();

sub run-my-service(%params, %context = {}) {
      my $service = CodeGolf::Service::BindNotificatorToCurrentSession.new(
          user-id     => 'koorchik',
          session-id  => 'test-session-123',
          user-role   => 'ADMIN',
          storage     => $storage,
          notificator => get-notificator-mock($storage, my $bot),
          tester      => get-nodejs-tester,
          |%context
      );

      return $service.run(%params);
}

subtest {
    my %data = run-my-service({name => 'MyTestGolf'});

    is %data<session-id>, 'test-session-123', "Session ID is set";
}, "Positive: should return bound session";


subtest {
    throws-like { run-my-service({}, { user-role => 'USER' }) },
        CodeGolf::Service::X::NotEnoughPermissions;
}, "Negative: USER not allowed to use this service";

done-testing;
