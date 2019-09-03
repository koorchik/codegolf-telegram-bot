use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use Test::CodeGolf::Factory;

use CodeGolf::Service::ShowRatingWithSources;

my $factory = Test::CodeGolf::Factory.new();
$factory.setup-golf();
$factory.setup-results();

sub run-my-service(%params = {}, %context = {}) {
      my $service = CodeGolf::Service::ShowRatingWithSources.new(
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
    my @results = run-my-service();
    isa-ok @results, Array, "Array of results";

    for @results -> %result {
        ok %result<user-id>, "User ID is set";
        isa-ok %result<code-length>, Int, "Code length is Int";
        ok %result<submited-at>, "SubmittedAt is set";
        ok %result<source-code>, "Source code is set";
    }

    ok(
        ([<=] @results.map(*<code-length>)),
        'Results are sorted by code length'
    );

}, "Positive: should return array of sorted results";


subtest {
    throws-like { run-my-service({}, { user-role => 'USER' }) },
        X::CodeGolf::Service::NotEnoughPermissions;
}, "Negative: USER not allowed to use this service";


done-testing;
