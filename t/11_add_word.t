#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Temp qw/tempfile/;
use File::Spec::Functions qw/catfile/;

use Test::Symbol::Spelling;

use Test::More;

subtest 'add_word' => sub {
    my ($fh, $filename) = tempfile('XXXXXX', UNLINK => 1);
    use_personal_dictionary $filename;

    add_word 'asdf';
    symbol_spelling_ok catfile($FindBin::Bin, 'resources', 'fail', 'fail1.pm');
};

subtest 'add_word_lc' => sub {
    my ($fh, $filename) = tempfile('XXXXXX', UNLINK => 1);
    use_personal_dictionary $filename;

    add_word_lc 'asdf';
    symbol_spelling_ok catfile($FindBin::Bin, 'resources', 'fail', 'fail5.pm');
};

done_testing;
