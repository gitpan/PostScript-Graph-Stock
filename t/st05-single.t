#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 5 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $stk = new PostScript::Graph::Stock();
ok($stk);

$stk->data_from_file("t/single.csv");
ok(1);

my $name = "st05-basic";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);
