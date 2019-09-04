use Telegram;
use CodeGolf::Storage;
use CodeGolf::Tester;
use CodeGolf::Telegram::ServiceDispatcher;
use CodeGolf::Telegram::Notificator;

my %COMMANDS =
    'submit' => {
        service-class      => 'CodeGolf::Service::SubmitResult',
        params-rx          => rx/"/"\w+\s+ $<source-code>=[.*] \s*/,
        response-formatter => -> %r { "Length '{%r<code-length>}' saved! ID={%r<id>}" }
    },
    'rating' => {
        service-class => 'CodeGolf::Service::ShowRating',
        response-formatter => -> @results {
            my $i = 1;
            @results.map({ "{$i++}. $^r<user-id>: $^r<code-length>" }).join("\n")
        }
    },
    'startGolf' => {
        service-class      => 'CodeGolf::Service::StartGolf',
        params-rx          => rx/"/"\w+\s+ $<name>=[.*] \s*/,
        response-formatter => -> %g { "Golf '{%g<name>}' started! ID={%g<id>}" }
    },
    'setGolfName' => {
        service-class      => 'CodeGolf::Service::SetGolfName',
        params-rx          => rx/"/"\w+\s+ $<name>=[.*] \s*/,
        response-formatter => -> %g { "Golf name changed to '{%g<name>}'!" }
    },
    'setGolfTests' => {
        service-class => 'CodeGolf::Service::SetGolfTests',
        params-rx     => rx/"/"\w+\s+ $<url>=[.*] \s*/,
        response-formatter => { "Golf tests refetched!" }
    },
    'ratingWithSources' => {
        service-class => 'CodeGolf::Service::ShowRatingWithSources',
        response-formatter => -> @results {
            my $i = 1;
            @results.map({ "{$i++}. $^r<user-id>: $^r<code-length>\nSOURCE: $^r<source-code>" }).join("\n")
        }
    },
    'notifyHere' => {
        service-class => 'CodeGolf::Service::BindNotificatorToCurrentSession',
        response-formatter => { "Notifications enabled" }
    },
    # 'help' => {
    #     service-class => 'CodeGolf::Service::Help,
    #     response-formatter => { "SupportedCommands" }
    # }
;

class CodeGolf::Telegram::BotApp {
    has $.telegram-bot-token is required;
    has @.golf-admins is required;
    has $.tests-docker-image is required;
    has $.db-path is required;

    has $!storage = CodeGolf::Storage.new( db-path => $!db-path );
    has $!tester  = CodeGolf::Tester.new( docker-image => $!tests-docker-image );
    has $!bot     = Telegram::Bot.new($!telegram-bot-token);
    has $!notificator = CodeGolf::Telegram::Notificator.new(
        bot     => $!bot,
        storage => $!storage
    );

    has $!dispatcher = CodeGolf::Telegram::ServiceDispatcher.new(
        commands        => %COMMANDS,
        bot             => $!bot,
        context-builder => sub ($msg) {
            my $user-id = $msg.sender.username || $msg.sender.id;

            return {
                notificator => $!notificator,
                storage     => $!storage,
                tester      => $!tester,
                user-id     => $user-id,
                user-role   => $user-id ∈ @!golf-admins ?? 'ADMIN' !! 'USER',
                session-id  => $msg.chat.id,
           };
        }
    );

    method start() {
        "START BOT".say;

        $!storage.init;
        $!dispatcher.start;
    }
}
