use LIVR;
LIVR::Validator.default-auto-trim(True);

use CodeGolf::Service::X::ValidationError;
use CodeGolf::Service::X::NotEnoughPermissions;

subset UserRole where * eq "USER"|"ADMIN";

class CodeGolf::Service::Base {
    has $.storage is required;
    has $.notificator is required;
    has $.tester is required;
    has $.user-id is required;
    has $.session-id is required;
    has UserRole $.user-role is required;

    method run(%params) {
        self.check-permissions();
        return self.execute( self.validate(%params) );
    }

    method validate(%params) {
        my $validator = LIVR::Validator.new(livr-rules => %.validation-rules);
        my $valid-params = $validator.validate(%params);

        if $valid-params.defined {
            return $valid-params;
        } else {
            CodeGolf::Service::X::ValidationError.new(
                errors => $validator.errors()
            ).throw;
        }
    }

    method check-permissions() {
        unless $.user-role ∈ @.allowed-roles {
            CodeGolf::Service::X::NotEnoughPermissions.new.throw;
        }
    }
}

# FIXME: without "no precompilation" it will fail on $validator.prepare();
# with error "Cannot invoke this object (REPR: Null; VMNull)"
# I do not the reason
# Similar issue https://github.com/jnthn/grammar-debugger/issues/42
no precompilation;
