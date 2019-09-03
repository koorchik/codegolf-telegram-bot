use CodeGolf::Service::Base;
use CodeGolf::Tester;
use CodeGolf::Service::X::ValidationError;
use JSON::Tiny;

class CodeGolf::Service::SubmitResult is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN', 'USER';

    my %.validation-rules =
        source-code => ["required", "string", {max_length => 500}]
    ;

    method execute(%params) {
        my %golf = $.storage.find-active-golf();
        my $tests = from-json( %golf<tests> );

        CodeGolf::Service::X::ValidationError.new(
            errors => {
              source-code => 'NO_TESTS'
            }
        ).throw unless $tests.elems;

        $.tester.run-all-tests(%params<source-code>, $tests);
        my $result-id = $.storage.insert-result(
            golf-id     => %golf<id>,
            user-id     => $.user-id,
            source-code => %params<source-code>
        );

        my %result = $.storage.find-result($result-id);
        $.notificator.notify-changes-in-rating(user-id => $.user-id);

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
        }
    }
}
