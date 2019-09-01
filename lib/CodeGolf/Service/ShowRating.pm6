use CodeGolf::Service::Base;

class CodeGolf::Service::ShowRating is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN', 'USER';
    has %.validation-rules = {};

    method execute(%params) {
        my %golf = $.storage.find-active-golf();
        my @results = $.storage.find-golf-results( %golf<id> );

        return @results.map( -> $r {{
            user-id     => $r<user-id>,
            code-length => $r<code-length>,
            submited-at => $r<submited-at>,
        }} ).sort(*<code-length>).unique( :as(*<user-id>) );
    }
}
