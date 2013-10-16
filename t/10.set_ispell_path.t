#!perl

use strict;
use warnings;
use utf8;

use Test::Symbol::Spelling;

use Test::More;

set_ispell_path 'foo/bar';
is $Lingua::Ispell::path, 'foo/bar';

done_testing;
