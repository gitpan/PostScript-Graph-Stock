#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 3 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;

my $stk = new PostScript::Graph::Stock(
	csv => 't/single.csv',
    );
ok($stk);

my $name = "st05-single";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);
