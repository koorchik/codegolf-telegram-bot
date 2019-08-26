unit module CodeGolf::Tester;
use File::Temp;

sub run-all-tests(Str $source-code, Array @tests) is export {
    for @tests -> $test {
        run-test($source-code, $test<input>, $test<expected>);
    }
}

sub run-test(Str $source-code, Str $input, Str $expected) {
    my $filename = save-code-to-tmp-file($source-code);
    my $got = run-file($filename, $input);

    if $got ne $expected {
        "GOT $got".say;
        "GOT $expected".say;
        die "TEST FAILED $input";
    }
}

sub save-code-to-tmp-file(Str $source-code) {
    my $tmp-dir = '/tmp/codegolf';
    mkdir($tmp-dir);

    my ($filename, $fh) = tempfile(:tempdir($tmp-dir), :!unlink);
    $fh.print($source-code);

    return $filename;
}

sub run-file(Str $filename, Str $input) {
    "run-file $input".say;
    my $image = 'node:12-alpine';

    my @command = 'docker',
        'run',
        '--rm',
        '-v',
        "$filename:/codegolf/script.code",
        $image,
        'node',
        '/codegolf/script.code',
        $input;

    # // TODO: Add timeouts
    my $proc = run @command, :out;
    return $proc.out.slurp;
}

