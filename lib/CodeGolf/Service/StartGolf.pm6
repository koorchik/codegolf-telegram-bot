use CodeGolf::Service::Base;

class CodeGolf::Service::StartGolf is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN', 'USER';

    has %.validation-rules = {
        name => ["required", "string", {max_length => 128}]
    };

    method execute(%params) {
        my $storage = self.storage;

        my $id = $storage.insert-golf(name => %params<name>);
        $storage.activate-golf($id);
        my %golf = $storage.find-golf($id);

        return %golf;
    }
}
