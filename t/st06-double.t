#!/usr/bin/perl
use strict;
use warnings;
use Test;
BEGIN { plan tests => 9 };
use PostScript::File qw(check_file);
use PostScript::Graph::Stock;
ok(1);

my $file = new PostScript::File(
		landscape => 1,
		left	  => 30,
		right     => 30,
		top       => 30,
		bottom    => 30,
	    );
ok($file);
my $stk1 = new PostScript::Graph::Stock(
		file => $file,
		heading => 'ARM-L',
	    );
ok($stk1);
$stk1->build_chart("t/ARM-L.csv");
ok(1);
$file->newpage();
ok(1);
my $stk2 = new PostScript::Graph::Stock(
		file => $file,
		heading => 'egg',
	    );
ok($stk2);
$stk2->build_chart("t/egg.csv");
ok(1);
my $name = "st06-double";
$file->output( $name, "test-results" );
ok(1); # survived so far
my $res = check_file( "$name.ps", "test-results" );
ok($res);
