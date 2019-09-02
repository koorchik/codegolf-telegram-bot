use lib 'lib';

use Test;
use Test::CodeGolf::Utils;
use Test::CodeGolf::Factory;

use CodeGolf::Service::ShowRating;

my $factory = Test::CodeGolf::Factory.new();
$factory.setup-golf();
$factory.setup-results();

sub run-my-service(%params = {}, %context = {}) {
      my $service = CodeGolf::Service::ShowRating.new(
          user-id     => 'koorchik',
          session-id  => 'aaaa',
          user-role   => 'USER',
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
        ok !%result<source-code>, "Not source code";
    }

    ok(
        ([<=] @results.map(*<code-length>)),
        'Results are sorted by code length'
    );

}, "Positive: should return array of sorted results";

done-testing;
