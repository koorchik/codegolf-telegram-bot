use CodeGolf::Service::Base;

class CodeGolf::Service::BindNotificatorToCurrentSession is CodeGolf::Service::Base {
    has @.allowed-roles = 'ADMIN';
    has %.validation-rules = { };

    method execute(%params) {
        $.notificator.bind-to-session($.session-id);

        return {
            session-id => $.session-id
        };
    }
}
