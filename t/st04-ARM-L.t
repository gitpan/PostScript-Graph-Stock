#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 5 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $stk = new PostScript::Graph::Stock(
	file => {
	    landscape => 1,
	    debug => 1,
	    errors => 1,
	    clip_command => "stroke",
	    clipping => 1,
	},
	by	     => 'days',
	heading      => 'ARM Holdings',
	background   => [1,1,0.9],
	color        => [0,0,1],
	width        => 2,
	shape        => 'stock2',
	outline_same => 1,
	bar_color    => [0,0.5,0.9],
	bar_width    => 0.5,
	bar_title    => "Volume",
	axis_title   => "Price in pence",
    );
ok($stk);

$stk->data_from_file("t/ARM-L.csv");
ok(1);

my $name = "st04-ARM-L";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);


