#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 6 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $stk = new PostScript::Graph::Stock(
	file => {
	    landscape => 1,
	    debug => 1,
	    errors => 1,
	    clip_command => 'stroke',
	    clipping => 1,
	},
	dates => 'days',
	price => {
	    show_lines => 1,
	    point_width => 1.5,
	    point_color => 0,
	},
    );
ok($stk);

$stk->data_from_file("t/stock60.csv");
ok(1);
$stk->build_chart();
ok(1);

my $name = "st02-stock60";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);
