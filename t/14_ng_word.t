#!perl

use strict;
use warnings;
use utf8;

use Test::Symbol::Spelling;

use Test::More;
use Test::Builder::Tester;

ng_word "foo";
ng_word "bar";
ng_word "user";

my $lib = glob "t/resources/succ/succ.pm";
test_out "not ok 1 - $lib";
symbol_spelling_ok $lib;
test_test (name => "testing ng_word", skip_err => 1);

done_testing;
