#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 5 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $stk = new PostScript::Graph::Stock(
	file	=> {
	    landscape => 1,
	    debug => 1,
	    errors => 1,
	    clipping => 1,
	},
	by	=> 'months',
	price	=> {
	    point_width => 2,
	    point_color => [1, 0.3, 0],
	},
	volume	=> {
	    bar_color => [0.5, 0.8, 1],
	},
    );
ok($stk);

$stk->data_from_file("t/small.csv");
ok(1);

my $name = "st01-small";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);


