use CodeGolf::Service::Base;
use JSON::Tiny;
use Cro::HTTP::Client;

class CodeGolf::Service::SetGolfTests is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN';

    my %.validation-rules =
        url => ["required", "string", "url"]
    ;

    method execute(%params) {
        my $resp = await Cro::HTTP::Client.get(%params<url>);
        my $body = await $resp.body;
        from-json($body).perl.say;

        my %golf = $.storage.find-active-golf();
        # $.storage.update-golf( %golf<id>, { name => %params<name> } );
        # my %updated-golf = $.storage.find-active-golf();
        my %updated-golf = %golf;
        return {
            id          => %updated-golf<id>,
            name        => %updated-golf<name>,
            is-active   => %updated-golf<is-active>,
            started-at  => %updated-golf<started-at>,
            finished-at => %updated-golf<finished-at>
        };
    }
}
