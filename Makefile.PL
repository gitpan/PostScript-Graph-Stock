use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'PostScript::Graph::Stock',
    'VERSION_FROM'	=> 'Stock.pm', # finds $VERSION
    'PREREQ_PM'		=> { PostScript::Graph::Paper => 0.05,
			     PostScript::File  => 0,
			     PostScript::Graph::Style => 0.03,
			     PostScript::Graph::Key   => 0,
			   },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Stock.pm', # retrieve abstract from module
      AUTHOR     => 'Christopher Willmot <chris@willmot.org.uk>') : ()),
);
