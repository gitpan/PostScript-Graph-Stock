#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 4 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $data = [
    ['1998-12-22',463.00,466.00,456.25,461.77,128495],
    ['1998-12-23',468.00,475.00,450.00,458.50,79882],
    ['1999-01-04',453.00,462.00,445.00,453.00,117992],
    ['1999-01-05',453.00,458.00,446.00,450.82,98473],
];

my $stk = new PostScript::Graph::Stock(
	file	=> {
	    landscape => 1,
	    debug => 1,
	    errors => 1,
	    clipping => 1,
	},
	array	=> $data,
	dates_by=> 'months',
	price	=> {
	    point_width => 2,
	    point_color => [1, 0.3, 0],
	},
	volume	=> {
	    bar_color => [0.5, 0.8, 1],
	},
    );
ok($stk);

my $name = "st01-small";
$stk->output( $name, "test-results" );
ok(1); # survived so far
my $file = check_file( "$name.ps", "test-results" );
ok($file);


