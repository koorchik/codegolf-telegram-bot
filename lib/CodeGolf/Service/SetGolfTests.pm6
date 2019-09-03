use CodeGolf::Service::Base;
use CodeGolf::Service::X::ValidationError;
use JSON::Tiny;
use Cro::HTTP::Client;
use LIVR;

class CodeGolf::Service::SetGolfTests is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN';

    my %.validation-rules =
        url => ["required", "string", "url"]
    ;

    method execute(%params) {
        my $resp = await Cro::HTTP::Client.get(%params<url>);
        my $json = await $resp.body;
        my $tests = from-json($json);

        self!validate-tests($tests);
        my %golf = $.storage.find-active-golf();

        $.storage.update-golf( %golf<id>, { tests => $json } );
        my %updated-golf = $.storage.find-active-golf();

        return {
            id          => %updated-golf<id>,
            name        => %updated-golf<name>,
            is-active   => %updated-golf<is-active>,
            started-at  => %updated-golf<started-at>,
            finished-at => %updated-golf<finished-at>
        };

        CATCH {
            when X::Cro::HTTP::Error::Client {
                CodeGolf::Service::X::ValidationError.new(
                    errors => { url => 'FETCHING_ERROR' }
                ).throw;
            }
            when X::JSON::Tiny::Invalid {
                CodeGolf::Service::X::ValidationError.new(
                    errors => { url => 'JSON_PARSING_ERROR' }
                ).throw;
            }
        }
    }

    method !validate-tests($tests) {
        my $validator = LIVR::Validator.new(livr-rules => {
            tests => ['required', {'list_of_objects' => {
                input    => ["required", "string"],
                expected => ["required", "string"]
            } }]
        });

        my $valid-data = $validator.validate({tests => $tests});

        unless $valid-data.defined {
            CodeGolf::Service::X::ValidationError.new(
                errors => {url => 'WRONG_JSON_STRUCTURE'}
            ).throw;
        }
    }
}
