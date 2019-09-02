use CodeGolf::Service::Base;

class CodeGolf::Service::BindNotificatorToCurrentSession is CodeGolf::Service::Base {
    my @.allowed-roles = 'ADMIN';
    my %.validation-rules;

    method execute(%params) {
        $.notificator.bind-to-session($.session-id);

        return {
            session-id => $.session-id
        };
    }
}
