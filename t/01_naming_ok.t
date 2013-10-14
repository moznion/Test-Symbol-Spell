#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Path::Tiny;
use File::Spec::Functions qw/catdir/;

use Test::Symbol::Spell;
use Test::More;

naming_ok catdir(path($FindBin::Bin)->dirname, "lib", "Test", "Symbol", "Spell.pm");

done_testing;
