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
	    debug => 2,
	    errors => 1,
	    clip_command => "stroke",
	    clipping => 1,
	},
	date => {
	    by => 'day',
	    changes => 1,
	    show_weekday => 1,
	    show_day => 1,
	    show_month => 1,
	    show_year => 1,
	},
	price => {
	    point_color => [1, 0.2, 0],
	    show_lines => 1,
	    x_axis => {
		mark_min => 4,
		mark_max => 8,
		heavy_color => [1,0,0],
		mid_color => [0,1,0],
		#light_color => [0,0,1],
	    },
	},
	volume => {
	    y_axis => {
		smallest => 4,
	    },
	    bar_color => [0, 0.3, 1],
	    show_lines => 1,
	},
    );
ok($stk);

$stk->data_from_file("t/egg.csv");
ok(1);
$stk->build_chart();
ok(1);

my $name = "st03-egg";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);

