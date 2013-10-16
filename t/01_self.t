#!perl

use strict;
use warnings;
use utf8;

use Test::Symbol::Spell;

use Test::More;

my $checker = Test::Symbol::Spell->new;
$checker->all_symbol_spell_ok;

done_testing;
