#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Path::Tiny;
use File::Spec::Functions qw/catdir/;

use Test::Symbol::Spell;
use Test::More;

my $checker = Test::Symbol::Spell->new;
$checker->symbol_spell_ok(catdir(path($FindBin::Bin)->dirname, "lib", "Test", "Symbol", "Spell.pm"));
$checker->symbol_spell_ok(catdir($FindBin::Bin, "resources", "succ", "succ.pm"));

done_testing;
