use lib '../lib';

use CodeGolf::Service::SubmitResult;

sub MAIN {
    my $service = CodeGolf::Service::SubmitResult.new(
        user-id    => 'koorchik',
        session-id => 'aaaa',
        user-role  => 'ADMIN'
    );

    my %params = source-code => "some code here";
    $service.run(%params);

    CATCH {
        when CodeGolf::Service::X::Base {
            .message.say
        } 
        default {
            .message.say;
            say "Server error happened";
        }
    }
}