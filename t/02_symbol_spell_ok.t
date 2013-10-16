#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Path::Tiny;
use File::Spec::Functions qw/catdir/;

use Test::Symbol::Spelling;
use Test::More;

symbol_spelling_ok catdir($FindBin::Bin, "resources", "succ", "succ.pm");

done_testing;
