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
	    clip_command => "stroke",
	    clipping => 1,
	},
	dates => 'days',
	changes_only => 1,
	show_weekday => 1,
	show_day     => 1,
	show_month   => 1,
	show_year    => 1,
	show_lines   => 1,
	heading      => 'Test chart',
	background   => [1,1,0.9],
	color        => [0,0,1],
	width        => 2,
	shape        => 'stock2',
	outline_same => 1,
	bar_color    => [0,0.5,0.9],
	bar_width    => 0.5,
	bar_title    => "Volume",
	axis_title   => "Price in pence",
	
	price => {
	    layout => {
		#background => [0.9, 0.9, 1],
		#heading => 'Command Line Specified',
	    },
	    y_axis => {
		#title => 'bbbbbb',
	    },
	    x_axis => {
		#mark_min => 2,
		#mark_max => 8,
		#heavy_color => [0.3,0.5,0.9],
		#mid_color => -1,
		#light_color => [0,0,1],
		#show_lines => 1,
	    },
	    style => {
		#same => 0,
		point => {
		    #shape => 'stock',
		    #inner_color => [1,0.5,0],
		    #inner_width => 1,
		    #outer_color => [1,0,0],
		    #outer_width => 2,
		},
	    },
	},
	volume => {
	    y_axis => {
		smallest => 4,
	    },
	    x_axis => {
		#show_lines => 1,
	    },
	    style => {
		bar => {
		    #outer_width => 4,
		    #outer_color => 0,
		    #inner_color => [0,1,0],
		},
	    },
	},
    );
ok($stk);

$stk->data_from_file("t/ARM-L.csv");
ok(1);
$stk->build_chart();
ok(1);

my $name = "st04-ARM-L";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);


