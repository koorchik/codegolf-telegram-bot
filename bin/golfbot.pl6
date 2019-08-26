use lib 'lib';

use CodeGolf::Telegram::BotApp;

my $token = '';
my @golf-admins = ('koorchik');
my $tests-docker-image = 'node:12';

my $golfbot = CodeGolf::Telegram::BotApp.new(
    telegram-bot-token => $token,
    golf-admins        => @golf-admins,
    tests-docker-image => $tests-docker-image
);

$golfbot.start();
