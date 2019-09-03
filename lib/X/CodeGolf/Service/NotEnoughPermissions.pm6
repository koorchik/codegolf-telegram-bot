use X::CodeGolf::Service::Base;

class X::CodeGolf::Service::NotEnoughPermissions is X::CodeGolf::Service::Base {
    method message() {
        "You do not have enough permissions for this!";
    }
}
