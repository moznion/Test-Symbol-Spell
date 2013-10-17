#!perl

use strict;
use warnings;
use utf8;

use Test::Symbol::Spelling;

use Test::More;

ok defined Test::Symbol::Spelling->can('allow_compounds');
ok defined Test::Symbol::Spelling->can('make_wild_guesses');
ok defined Test::Symbol::Spelling->can('use_dictionary');
ok defined Test::Symbol::Spelling->can('use_personal_dictionary');

done_testing;
