#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use Path::Tiny;
use File::Spec::Functions qw/catdir/;

use Test::Naming::Spell;
use Test::More;

naming_ok catdir(path($FindBin::Bin)->dirname, "lib", "Test", "Naming", "Spell.pm");

done_testing;
