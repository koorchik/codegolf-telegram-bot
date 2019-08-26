use CodeGolf::Service::X::Base;

class CodeGolf::Service::X::ValidationError is CodeGolf::Service::X::Base {
    has %.errors is required;

    method message() {
        "Cannot execute command. Error: {%.errors.gist}";
    }
}
