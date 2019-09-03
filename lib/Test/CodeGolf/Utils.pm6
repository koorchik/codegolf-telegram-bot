use File::Temp;
use CodeGolf::Storage;
use CodeGolf::Tester;
use CodeGolf::Telegram::Notificator;

sub get-tmp-storage is export {
    my ($filename) = tempfile("testdb-******.sqlite3", :!unlink);
    my $storage = CodeGolf::Storage.new(db-path => $filename);
    $storage.init;

    $storage.save-notificator-setting({session-id => 'notification-session'});

    return $storage;
}

sub get-nodejs-tester is export {
    return CodeGolf::Tester.new(docker-image => 'node:12-alpine');
}

sub get-notificator-mock($storage, $bot is rw) is export {
    my class Bot {
        has $.last-message;
        method sendMessage(:$chat_id, :$text) {
            $!last-message = $text;
        }
    }

    $bot = Bot.new;

    return CodeGolf::Telegram::Notificator.new(
        storage => $storage,
        bot     => $bot
    );
}
