use CodeGolf::Service::Base;

class CodeGolf::Service::SubmitResult is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN', 'USER';

    has %.validation-rules = {
        source-code => ["required", "string", {max_length => 500}]
    };

    method execute(%params) {
        "EXECUTING with {%params.gist}".say;

        # self.notificator.notify('CHANGES_IN_RATING', {
        #   user-id  => 'koorchik'
        # });

        return {
            "Top Players" => [
                {user-id => "koorchik", length => 22},
                {user-id => "koorchik", length => 33},
                {user-id => "koorchik", length => 55}
            ]
        };

        # $self.notificator.notifyUpdatedScores();
    }
}
