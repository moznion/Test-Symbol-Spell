#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec::Functions qw/catdir/;

use Test::Symbol::Spelling;
use Test::More;

symbol_spelling_ok catdir($FindBin::Bin, "resources", "succ", "succ.pm");

done_testing;
