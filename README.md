# codegolf-telegram-bot

Code Golf Telegram Bot (can be used with any programming language)

With this bot you can make code golf competitions via telegram.

## Installation
1. Install Perl 6
2. Install Docker
3. Install Zef
4. `zef install --deps-only --force-test .`
5. `zef install App::Prove6`
6. `prove6` should pass all tests
7. `perl6 bin/golfbot.pl6 --tg-token='MY-KEY' --admins=user1,user2 --tests-docker-image="node:12-alpine"`

## Telegram bot usage

1. Create new telegram bot.
2. Create common chat for all golf participants and the bot to it.
3. Start new golf.
4. Participants should submit there result directly to bot chat. Not in group chat!


### USER commands

* /submit <source-code>
* /rating

### ADMIN commands

* /submit <source-code>
* /rating
* /startGolf <golf-name>
* /setGolfName <golf-name>
* /setGolfTests <url-to-json-with-tests>
* /ratingWithSources
* /notifyHere
