#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Path::Tiny;
use File::Spec::Functions qw/catdir/;

use Test::Symbol::Spelling;
use Test::More;

my $checker = Test::Symbol::Spelling->new;
$checker->symbol_spell_ok(catdir(path($FindBin::Bin)->dirname, "lib", "Test", "Symbol", "Spelling.pm"));
$checker->symbol_spell_ok(catdir($FindBin::Bin, "resources", "succ", "succ.pm"));

done_testing;
