#!perl

use strict;
use warnings;
use utf8;

use Test::Symbol::Spelling;

use Test::More;

my $checker = Test::Symbol::Spelling->new;
$checker->all_symbol_spell_ok;

done_testing;
