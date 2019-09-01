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
        my @tests = (
            { "input" => "123",  "expected" => "246\n" },
            { "input" => "1234", "expected" => "2468\n" }
        );

        $.tester.run-all-tests(%params<source-code>, @tests);

        my %golf = $.storage.find-active-golf();
        my $result-id = $.storage.insert-result(
            golf-id     => %golf<id>,
            user-id     => $.user-id,
            source-code => %params<source-code>
        );

        my %result = $.storage.find-result($result-id);

        return {
            id          => %result<id>,
            golf-id     => %result<golf-id>,
            user-id     => %result<user-id>,
            code-length => %result<code-length>,
            submited-at => %result<submited-at>,
            source-code => %result<source-code>
        };

        CATCH {
            when CodeGolf::Tester::X {
              CodeGolf::Service::X::ValidationError.new(
                  errors => {
                    source-code => 'TESTING_FAILED'
                  }
              ).throw;
            }
            default {
                die $_;
            }
        }

        # self.notificator.notify('CHANGES_IN_RATING', {
        #   user-id  => 'koorchik'
        # });
        # $self.notificator.notifyUpdatedScores();
    }
}
