use CodeGolf::Service::Base;

class CodeGolf::Service::StartGolf is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN';

    my %.validation-rules = 
        name => ["required", "string", {max_length => 128}]
    ;

    method execute(%params) {
        my $id = $.storage.insert-golf(name => %params<name>);
        $.storage.activate-golf($id);
        my %golf = $.storage.find-golf($id);

        return {
            id          => %golf<id>,
            name        => %golf<name>,
            is-active   => %golf<is-active>,
            started-at  => %golf<started-at>,
            finished-at => %golf<finished-at>
        };
    }
}
