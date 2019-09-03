use X::CodeGolf::Service::Base;

class X::CodeGolf::Service::ValidationError is X::CodeGolf::Service::Base {
    has %.errors is required;

    method message() {
        "Cannot execute command. Error: {%.errors.gist}";
    }
}
