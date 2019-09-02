use lib 'lib';

use CodeGolf::Telegram::BotApp;
#
# my $token = %*ENV<TELEGRAM_TOKEN>;
# my @golf-admins = %*ENV<GOLF_ADMINS>.split(',');
# my $tests-docker-image = %*ENV<TESTS_DOCKER_IMAGE> ;

sub MAIN(Str :$tg-token!, Str :$admins!, Str :$tests-docker-image! ) {
    my $golfbot = CodeGolf::Telegram::BotApp.new(
        telegram-bot-token => $tg-token,
        golf-admins        => $admins.split(','),
        tests-docker-image => $tests-docker-image
    );

    $golfbot.start();
}
