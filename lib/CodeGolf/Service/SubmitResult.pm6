use CodeGolf::Service::Base;
use CodeGolf::Tester;
use JSON::Tiny;
use CodeGolf::Service::X::ValidationError;


class CodeGolf::Service::SubmitResult is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN', 'USER';

    has %.validation-rules = {
        source-code => ["required", "string", {max_length => 500}]
    };

    method execute(%params) {
        "EXECUTING with {%params.gist}".say;

        my $tester = CodeGolf::Tester.new(
            docker-image => 'node:12-alpine'
        );

        my @tests = [
            {
                "input"    => "123",
                "expected" => "123\n35\n8\n"
            },
            {
                "input" => "9000",
                "expected" => "9000\n900\n90\n9\n"
            }
        ];

        $tester.run-all-tests(%params<source-code>, @tests);


        CATCH {
            CodeGolf::Service::X::ValidationError.new(
                errors => {
                  source-code => 'TEST_FAILED'
                }
            ).throw;
        }
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
