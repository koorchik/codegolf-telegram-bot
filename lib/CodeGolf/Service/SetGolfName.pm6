use CodeGolf::Service::Base;

class CodeGolf::Service::SetGolfName is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN', 'USER';

    has %.validation-rules = {
        name => ["required", "string", {max_length => 128}]
    };

    method execute(%params) {
        my %golf = self.storage.find-active-golf();

        self.storage.update-golf( %golf<id>, { name => %params<name> } );

        return %golf;
    }
}
