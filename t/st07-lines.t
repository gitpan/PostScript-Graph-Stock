#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 11 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $stk = new PostScript::Graph::Stock(
	file => {
	    landscape => 1,
	    debug => 1,
	    errors => 1,
	},
	dates => {
	    by		 => 'days',
	    changes_only => 0,
	    show_weekday => 0,
	    show_day     => 1,
	    show_month   => 1,
	    show_year    => 0,
	    show_lines   => 1,
	},
	heading      => 'Test chart',
	background   => [1,1,0.9],
	color        => [0,0,1],
	width        => 1,
	shape        => 'stock2',
	bgnd_outline => 1,
	bar_color    => [0,0.5,0.9],
	bar_width    => 0.5,
	volume_title => "Contracts exchanged",
	price_title  => "Price in pence",
	smallest     => 4,
	price_percent => 50,
	analysis_percent => 25,
	volume_percent => 25,
	analysis_low => -3,
	analysis_high => 7,
    );
ok($stk);

$stk->data_from_file("t/ARM-L.csv");
ok(1);

my $pdata1 = [
	[ '2002-03-20', 250 ],
	[ '2002-04-04', 230 ],
	[ '2002-04-29', 160 ],
    ];
    
my $pstyle1 = { 
	auto    => 'none',
	color   => 1,
	line    => {
	    width	=> 1,
	    color	=> [0.7, 0, 0],
	    dashes	=> [9, 2],
	},
	point   => {
	    size	=> 6,
	    shape	=> 'dot',
	    color	=> [1, 0.3, 0],
	},
    };
    
$stk->add_price_line( $pdata1, 'First', $pstyle1 );
ok(1);

my $pdata2 = [
	[ '2002-05-20', 240 ],
	[ '2002-06-19', 170 ],
	[ '2002-07-16', 180 ],
    ];
    
my $pstyle2 = { 
	auto    => 'none',
	color   => 1,
	line    => {
	    width	=> 0.5,
	    color	=> [0, 0.7, 0],
	},
	point   => {
	    size	=> 3,
	    shape	=> 'square',
	    color	=> [0.2, 1, 0.2],
	},
    };
    
$stk->add_price_line( $pdata2, 'Second', $pstyle2 );
ok(1);

my $astyle = {
	auto => [qw(dashes green blue)],
	use_color => 1,
	line => {
	    width => 0.5,
	},
    };
    
my $adata1 = [
	[ '2002-03-20', -3 ],
	[ '2002-04-15', 0, ],
	[ '2002-06-10', 5 ],
    ];
    
$stk->add_analysis_line( $adata1, 'First line', $astyle );
ok(1);

my $adata2 = [
	[ '2002-05-29', 7 ],
	[ '2002-07-04', 2 ],
	[ '2002-08-12', -2 ],
    ];
    
$stk->add_analysis_line( $adata2, 'Second line', $astyle );
ok(1);

my $vdata1 = [
	[ '2002-03-20', 20000000 ],
	[ '2002-04-15', 70000000 ],
	[ '2002-06-10', 50000000 ],
    ];
    
$stk->add_volume_line( $vdata1, 'First volume' );
ok(1);

my $vdata2 = [
	[ '2002-05-29', 15000000 ],
	[ '2002-07-04', 20000000 ],
	[ '2002-08-12', 70000000 ],
    ];
    
$stk->add_volume_line( $vdata2, 'Second volume' );
ok(1);

my $name = "st07-ARM-L";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);


