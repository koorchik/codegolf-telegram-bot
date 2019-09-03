use lib 'lib';
use CodeGolf::Telegram::BotApp;

sub MAIN(Str :$tg-token!, Str :$admins!, Str :$tests-docker-image! ) {
    my $golfbot = CodeGolf::Telegram::BotApp.new(
        telegram-bot-token => $tg-token,
        golf-admins        => $admins.split(','),
        tests-docker-image => $tests-docker-image,
        db-path            => 'codegolf-db.sqlite3'
    );

    $golfbot.start();
}
