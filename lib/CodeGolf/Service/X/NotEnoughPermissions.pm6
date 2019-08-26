use CodeGolf::Service::X::Base;

class CodeGolf::Service::X::NotEnoughPermissions is CodeGolf::Service::X::Base {
    method message() {
        "You do not have enough permissions for this!";
    }
}