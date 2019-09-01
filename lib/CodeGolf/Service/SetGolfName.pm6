use CodeGolf::Service::Base;

class CodeGolf::Service::SetGolfName is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN';

    has %.validation-rules = {
        name => ["required", "string", {max_length => 128}]
    };

    method execute(%params) {
        my %golf = $.storage.find-active-golf();
        $.storage.update-golf( %golf<id>, { name => %params<name> } );
        return $.storage.find-active-golf();
    }
}
