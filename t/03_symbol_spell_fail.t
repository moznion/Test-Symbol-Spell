#!perl

use strict;
use warnings;
use utf8;

use FindBin;
use File::Spec::Functions qw/catdir/;

use Test::Symbol::Spelling;

use Test::More;
use Test::Builder::Tester;

my @libs = glob "t/resources/fail/*";
for my $lib (@libs) {
    test_out "not ok 1 - $lib";
    symbol_spelling_ok $lib;
    test_test (name => "testing symbol_spelling_ok", skip_err => 1);
}

done_testing;
