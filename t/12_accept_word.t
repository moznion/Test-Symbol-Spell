#!perl

use strict;
use warnings;
use utf8;
use FindBin;
use File::Spec::Functions qw/catfile/;

use Test::Symbol::Spelling;

use Test::More;

accept_word "asdf";
symbol_spelling_ok catfile($FindBin::Bin, 'resources', 'fail', 'fail1.pm');

done_testing;
