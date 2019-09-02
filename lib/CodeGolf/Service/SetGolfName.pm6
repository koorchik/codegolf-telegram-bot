use CodeGolf::Service::Base;

class CodeGolf::Service::SetGolfName is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN';

    my %.validation-rules =
        name => ["required", "string", {max_length => 128}]
    ;

    method execute(%params) {
        my %golf = $.storage.find-active-golf();
        $.storage.update-golf( %golf<id>, { name => %params<name> } );
        my %updated-golf = $.storage.find-active-golf();

        return {
            id          => %updated-golf<id>,
            name        => %updated-golf<name>,
            is-active   => %updated-golf<is-active>,
            started-at  => %updated-golf<started-at>,
            finished-at => %updated-golf<finished-at>
        };
    }
}
