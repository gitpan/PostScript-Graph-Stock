use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'PostScript::Graph::Stock',
    'VERSION_FROM'	=> 'Stock.pm', # finds $VERSION
    'PREREQ_PM'		=> { Text::CSV_XS => 0,
			     Date::Pcalc => 0,
			     PostScript::File  => 0.08,
			     PostScript::Graph::Paper => 0.06,
			     PostScript::Graph::Style => 0.03,
			     PostScript::Graph::Key   => 0.04,
			     Finance::Shares::Sample  => 0.01,
			   },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Stock.pm', # retrieve abstract from module
      AUTHOR     => 'Christopher Willmot <chris@willmot.co.uk>') : ()),
);
