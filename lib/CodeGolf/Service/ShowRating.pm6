use CodeGolf::Service::Base;

class CodeGolf::Service::ShowRating is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN', 'USER';
    my %.validation-rules;

    method execute(%params) {
        my %golf = $.storage.find-active-golf();
        my @results = $.storage.find-golf-results( %golf<id> );

        return @results.map( -> %r {{
            user-id     => %r<user-id>,
            code-length => %r<code-length>,
            submited-at => %r<submited-at>,
        }} ).sort(*<code-length>).unique( :as(*<user-id>) );
    }
}
