#!perl

use strict;
use warnings;
use utf8;

use Test::Symbol::Spelling;

use Test::More;

accept_word 'ng';
accept_word 'PPI';
accept_word 'lc';
accept_word 'dict';

all_symbol_spelling_ok;

done_testing;
