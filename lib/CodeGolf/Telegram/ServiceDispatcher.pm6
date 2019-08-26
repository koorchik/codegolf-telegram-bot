use Telegram;
use CodeGolf::Service::X::Base;

class CodeGolf::Telegram::ServiceDispatcher {
    has $.telegram-bot-token is required;
    has %.commands is required;
    has &.context-builder is required;

    has $!bot = Telegram::Bot.new($!telegram-bot-token);

    method start() {
        $!bot.start(interval => 1);

        react {
            whenever $!bot.messagesTap -> $msg {
                my $result = self!dispatch($msg);

                if $result {
                    my $text = self!url-escape($result);
                    $!bot.sendMessage(chat_id => $msg.chat.id, text => $text);
                }

                CATCH {
                    when CodeGolf::Service::X::Base {
                        my $text = self!url-escape(.message);
                        $!bot.sendMessage(chat_id => $msg.chat.id, text => $text);
                    }
                    default {
                        say "Server error happened";
                        .message.say;
                        my $text = self!url-escape(.message);
                        $!bot.sendMessage(chat_id => $msg.chat.id, text => $text);
                    }
                }
            }
            whenever signal(SIGINT) {
                $!bot.stop;
                exit;
            }
        }
    }

    method !dispatch($msg) {
        if $msg.text ~~ /^"/"(\w+)/ {
            (my $service-class, my $params-rx, my $response-formatter)
                = %.commands{$0}{"service-class", "params-rx", "response-formatter"};

            return "" unless $service-class;

            my %params = $params-rx.defined && ($msg.text ~~ $params-rx)
                ?? $/.hash
                !! { };

            for %params.kv -> $k, $v {
                # convert Match objects to string
                %params{$k} = Str($v)
            }

            "Loading and executing [$service-class]".say;
            "Params {%params.gist}".say;

            require ::($service-class);

            my $service = ::($service-class).new(
                |&.context-builder.($msg)
            );

            my $result = $service.run(%params);
            return $response-formatter ~~ Code ?? $response-formatter($result) !! $result;
        }

        return "";
    }

    method !url-escape($str) {
        return $str.subst(/<-alnum>/, *.ord.fmt("%%%02X"), :g);
    }
}
