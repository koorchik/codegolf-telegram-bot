
class CodeGolf::Telegram::Notificator {
    has $.storage is required;
    has $.bot is required;

    method bind-to-session($session-id!) {
        $.storage.save-notificator-setting({session-id => $session-id});
    }

    method notify-changes-in-rating(:$user-id!) {
        my %settings = $.storage.load-notificator-setting();
        return unless %settings<session-id>;

        # Find results for active golf
        my %golf = $.storage.find-active-golf();
        my @results = $.storage.find-golf-results( %golf<id> );

        # Find last two results
        (my $last, my $prev) = @results.grep(
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

        $.bot.sendMessage(
            chat_id => %settings<session-id>,
            text => self!url-escape($message)
        );
    }

    method !url-escape($str) {
        return $str.subst(/<-alnum>/, *.ord.fmt("%%%02X"), :g);
    }
}
