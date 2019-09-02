use lib 'lib';

use Test::CodeGolf::Factory;

sub MAIN {
    my $factory = Test::CodeGolf::Factory.new();
    $factory.setup-golf();
    $factory.setup-results();
    my $storage = $factory.storage;
    my $user-id = 'mykola';

    $storage.save-notificator-setting({session-id => 'AAAABBB'});

    my %settings = $storage.load-notificator-setting();

    # Find results for active golf
    my %golf = $storage.find-active-golf();
    my @results = $storage.find-golf-results( %golf<id> );

    # Find last two results
    my ($last, $prev) = @results.grep(
        *<user-id> eq $user-id
    ).sort(-*<id>)[0,1];

    return unless $last;

    # Find user position in rating
    my @rating = @results.sort(*<code-length>).unique( :as(*<user-id>) );
    my $user-best-result = @rating.first(*<user-id> eq $user-id);
    return if $user-best-result<id> ne $last<id>;

    my $new-position = 1;
    for @rating {
        last if $_<id> eq $last<id>;
        $new-position++;
    }

    # Prepare notification message
    my $message = $last && $prev && ($last<code-length> < $prev<code-length>)
        ?? "{$new-position++}. $last<user-id>: $last<code-length> (was $prev<code-length>)"
        !! "{$new-position++}. $last<user-id>: $last<code-length> (NEW)";

    say $message;
}
