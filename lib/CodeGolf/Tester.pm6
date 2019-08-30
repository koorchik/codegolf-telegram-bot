use File::Temp;

class CodeGolf::Tester::X is Exception {
    has $.input is required;
    has $.expected is required;
    has $.got is required;
}

class CodeGolf::Tester {
    has $.docker-image is required;

    method run-all-tests(Str $source-code, @tests) {
        for @tests -> $test {
            self!run-test($source-code, $test<input>, $test<expected>);
        }
    }

    method !run-test(Str $source-code, Str $input, Str $expected) {
        my $filename = self!save-code-to-tmp-file($source-code);
        my $got = self!run-file($filename, $input);

        if $got ne $expected {
            CodeGolf::Tester::X.new(
                input    => $input,
                expected => $expected,
                got      => $got
            ).throw;
        }
    }

    method !save-code-to-tmp-file(Str $source-code) {
        my $tmp-dir = '/tmp/codegolf';
        mkdir($tmp-dir);

        my ($filename, $fh) = tempfile(:tempdir($tmp-dir), :!unlink);
        $fh.print($source-code);

        return $filename;
    }

    method !run-file(Str $filename, Str $input) {
        "run-file $input".say;

        my @command = 'docker',
            'run',
            '--rm',
            '-v',
            "$filename:/codegolf/script.code",
            $.docker-image,
            'node',
            '/codegolf/script.code',
            $input;

        # // TODO: Add timeouts
        my $proc = run @command, :out;
        return $proc.out.slurp;
    }
}
