use Telegram;
use CodeGolf::Storage;
use CodeGolf::Telegram::ServiceDispatcher;

my %COMMANDS =
    'submit' => {
        service-class      => 'CodeGolf::Service::SubmitResult',
        params-rx          => rx/"/"\w+\s+ $<source-code>=[.*] \s*/,
        response-formatter => { "" }
    },
    'rating' => {
        service-class => 'CodeGolf::Service::ShowRating'
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
        params-rx     => rx/"/"\w+\s+ $<url>=[.*] \s*/
    },
    'ratingsWithSources' => {
        service-class => 'CodeGolf::Service::ShowRatingWithScores'
    },
    'notifyHere' => {
        service-class => 'CodeGolf::Service::BindNotificatorToCurrentSession'
    }
;

class CodeGolf::Telegram::BotApp {
    has $.telegram-bot-token is required;
    has @.golf-admins is required;
    # has $.tests-docker-image is required;

    has $!storage = CodeGolf::Storage.new();
    has $!dispatcher = CodeGolf::Telegram::ServiceDispatcher.new(
        telegram-bot-token => $!telegram-bot-token,
        commands           => %COMMANDS,
        context-builder    => sub ($msg) {
           return {
              storage    => $!storage,
              user-id    => $msg.sender.username,
              user-role  => 'ADMIN',
              session-id => $msg.chat.id,
           };
        }
    );

    method start() {
        "Starting bot...".say;

        $!storage.init;
        $!dispatcher.start;
    }
}
