#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 3 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;

my $stk = new PostScript::Graph::Stock(
	file	=> {
	    landscape => 1,
	    errors => 1,
	    clipping => 1,
	},
	dates_by=> 'days',
	csv	=> 't/stock60.csv',
	price	=> {
	    show_lines => 1,
	    point_width => 1.5,
	    point_color => 0,
	},
    );
ok($stk);

my $name = "st02-stock60";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);
