use CodeGolf::Service::Base;

class CodeGolf::Service::ShowRatingWithSources is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN';
    has %.validation-rules = {};

    method execute(%params) {
        my %golf = $.storage.find-active-golf();
        my @results = $.storage.find-golf-results( %golf<id> );

        return @results.map( -> $r {{
            user-id     => $r<user-id>,
            code-length => $r<code-length>,
            submited-at => $r<submited-at>,
            source-code => $r<source-code>,
        }} ).sort(*<code-length>).unique( :as(*<user-id>) );
    }
}
