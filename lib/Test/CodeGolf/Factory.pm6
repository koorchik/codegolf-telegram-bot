use Test::CodeGolf::Utils;
use JSON::Tiny;

class Test::CodeGolf::Factory {
    has $.storage = get-tmp-storage();

    method setup-golf {
        my $id = $.storage.insert-golf(name => 'MyGolf');
        $.storage.activate-golf($id);
        $.storage.update-golf($id, { tests => to-json([
            { "input" => "123",  "expected" => "246\n" },
            { "input" => "1234", "expected" => "2468\n" }
        ])});
    }

    method setup-results {
        my %golf = $.storage.find-active-golf();

        my @samples = (
            { user-id => 'mykola', source-code => 'console.log(1);console.log(2);console.log(3)'},
            { user-id => 'ninja',  source-code => 'console.log(1);console.log(2);console.log(3)'},
            { user-id => 'mykola', source-code => 'console.log(1234)'},
            { user-id => 'ivan',   source-code => 'console.log(1234);console.log(1234)'},
            { user-id => 'ninja',  source-code => 'console.log(1);console.log(2);'},
            { user-id => 'man677', source-code => 'console.log(1);console.log(2);console.log(3)'},
            { user-id => 'john',   source-code => 'console.log(1);console.log(2);console.log(3)'},
            { user-id => 'john',   source-code => 'console.log(123)'}
        );

        for @samples -> %sample {
            $.storage.insert-result(
                golf-id     => %golf<id>,
                user-id     => %sample<user-id>,
                source-code => %sample<source-code>
            );
        }
    }
}
