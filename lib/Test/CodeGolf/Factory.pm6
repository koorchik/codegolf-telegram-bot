use Test::CodeGolf::Utils;

class Test::CodeGolf::Factory {
    has $.storage = get-tmp-storage();

    method setup-golf {
        my $id = $!storage.insert-golf(name => 'MyGolf');
        $.storage.activate-golf($id);
    }
}
