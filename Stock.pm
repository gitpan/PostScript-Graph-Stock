package PostScript::Graph::Stock;
use strict;
use warnings;
use Text::CSV_XS;
use Date::Pcalc qw(:all);
use PostScript::File qw(check_file);
use PostScript::Graph::Bar;

our $VERSION = '0.02';

=head1 NAME

PostScript::Graph::Stock - draw share price graph from CSV data

=head1 SYNOPSIS

=head2 Simplest

Take a CSV file such as that produced by !Yahoo Finance websites (called 'stock_prices.csv' here), draw a graph
showing the price and volume data and output as a postscript file for printing ('graph.ps' in this example).

    use PostScript::Graph::Stock;

    my $pgs = new PostScript::Graph::Stock();
    $pgs->build_chart( 'stock_prices.csv' );
    $pgs->output( 'graph' );

=head2 Typical

A number of settings are provided to configure the graph's appearance, adding colour for example.  The ability to
add analysis lines to either chart is planned.

    use PostScript::Graph::Stock;

    my $pgs = new PostScript::Graph::Stock(
	heading        => 'MyCompany Shares',
	price_title    => 'Price in pence',
	volume_title   => 'Transaction volume',
	price_percent  => 75,
	volume_percent => 25,
	background     => [1, 1, 0.9],
	show_lines     => 1,
	x_heavy_color  => [0, 0, 0.6],
	x_heavy_width  => 0.8,
	x_mid_color    => [0.2, 0.6, 0.8],
	x_mid_width    => 0.8,
	x_light_color  => [0.5, 0.5, 1],
	x_light_width  => 0.25,
	y_heavy_color  => 0.3,
	y_heavy_width  => 0.8,
	y_mid_color    => 0.5,
	y_mid_width    => 0.8,
	y_light_color  => 0.7,
	y_light_width  => 0.25,
	days           => [qw(- Mon Dien Mitt ...)],
	months         => [qw(- Jan Feb Mars ...)],
	dates          => 'weeks',
	changes_only   => 1,
	show_weekday   => 1,
	show_day       => 1,
	show_month     => 1,
	show_year      => 1,
	color          => [1, 0, 0],
	width          => 1.5,
	shape          => 'close2',
	bgnd_outline   => 1,
	bar_color      => [0.8, 0.4, 0.15],
	bar_width      => 0.5,
    );
    $pgs->data_from_file( 'stock_prices.csv' );
    #$pgs->line_from_file( 'analysis.csv' );
    $pgs->build_chart();
    $pgs->output( 'graph' );

=head2 All options

Although a number of options are provided for convenience (see L</"Typical">), many of these are merely
a selection of the options which can be given to the underlying objects.  See the manpages for the options
available in each of the modules mentioned.

    use PostScript::Graph::Stock;

    my $pgs = new PostScript::Graph::Stock(
	file   => {
	    # for PostScript::File
	},
	
	price  => {
	    # options for Price graph
	    layout => {
		# General proportions, headings
		# for PostScript::Graph::Paper
	    },
	    x_axis => {
		# All settings for X axis
		# for PostScript::Graph::Paper
	    },
	    y_axis => {
		# All settings for Y axis
		# for PostScript::Graph::Paper
	    },
	    style  => {
		# Appearance of price points
		# for PostScript::Graph::Style
	    },
	    key    => {
		# Settings for Key area if there is one
		# for PostScript::Graph::Key
	    },
	},
	
	volume => {
	    # options for Volume bar chart
	    layout => {
		# General proportions, headings
		# for PostScript::Graph::Paper
	    },
	    x_axis => {
		# All settings for X axis
		# for PostScript::Graph::Paper
	    },
	    y_axis => {
		# All settings for Y axis
		# for PostScript::Graph::Paper
	    },
	    style  => {
		# Appearance of volume bars 
		# for PostScript::Graph::Style
	    },
	    key    => {
		# Settings for Key area if there is one
		# for PostScript::Graph::Key
	    },
	},
    );
    
    $pgs->build_chart( 'stock_prices.csv' );
    $pgs->output( 'graph' );

=head1 DESCRIPTION

This is a top level module in the PostScript::Graph series.  It produces graphs of stock performance given data in
either of the following formats.  The first extract was obtained by requesting price quotes in CSV file format from
http://uk.table.finance.yahoo.com/, the second from a query of a Finance::Shares::MySQL database.

    Date,Open,High,Low,Close,Volume
    31-Dec-01,448.75,448.75,438.00,439.48,986598
    28-Dec-01,445.00,447.25,438.00,444.52,3492096
    27-Dec-01,440.00,444.75,435.25,444.06,1053161

    Date,Open,High,Low,Close,Volume 
    2001-06-01,454.50,475.00,448.50,461.00,8535680
    2001-06-04,465.00,465.00,458.50,459.00,3254045
    2001-06-05,458.25,464.00,455.00,462.00,4615016

Options given to the constructor control the appearance of the chart.  The data can be given as a CSV file
to C<data_from_file> or as an array passed to C<data_from_array>.  It will shortly be possible to superimpose
linear graphs on the same charts by calling C<line_from_file> or C<line_from_array>.  The chart is comitted to
postscript format in C<build_chart> and saved to a postscript file with the C<output> function.  This file can be
either a printable *.ps file or an Encapsulated PostScript file for inclusion elsewhere.

The data is displayed as two charts showing price and volume.  These only appear if there is suitable data:
only a price chart is shown if the file has no volume data.  The proportion of space allocated for each is
configurable.  A Key is shown at the right of the relevant graph when analysis lines are added.

Theoretically, many years' worth of quotes can be accomodated, although the processing time becomes increasingly
obvious.  The output device tends to impose a practical limit, however.  For example, around 1000 vertical lines
can be distinguished on an A4 landscape sheet at 300dpi - 3 years of data at a pinch.  But it gets difficult to
read beyond 6-9 months.  To help with this, it is possible to simplify the output.

=head2 Example 1

To show only the closing values for the last day of each week, use these options:

   dates => 'weeks',
   shape => 'close',


The vertical scales largely look after themselves, although you might wish to add a bit of colour as all defaults
are monochrome.  The horizontal scale showing the dates requires a little more care.  The module tries to ensure
labels are always legible by missing some out if they become too crowded.  This is indicated by minor lines
appearing between the labels.  If this is likely, the following settings are recommended.

    show_lines   => 1,
    changes_only => 0,

When C<changes_only> is on (the default) the month name, for example, is only shown for the first day of a new
month.  But this could well be one of the dates omitted through over-crowding, in which case the labels may become
misleading.

Apart from that, the defaults will probably be satisfactory if you have a monochrome printer.  However, as there
are over 300 configurable options, a couple of examples might be useful.

=head2 Example 2

Vertical lines can be shown and both set to red using top-level options:

    show_lines    => 1,
    x_heavy_color => [1, 0, 0],

Or the axis options may be set directly.  Note that options unique to this package, such as 'show_lines' are only
available at the top level.
	
    show_lines => 1,
    price      => { 
	x_axis =>
	    heavy_color => [1, 0, 0],
	},
    },
    volume     => { 
	x_axis =>
	    heavy_color => [1, 0, 0],
	},
    },

=head2 Example 3 

Some things cannot be done directly using the top-level shortcuts.  Here the X axis marks are made more prominent
and the labels are printed in dark green 8pt Courier.

    price => {
	x_axis => {
	    mark_min   => 5,
	    mark_max   => 20,
	    font       => 'Courier',
	    font_size  => 8,
	    font_color => [0, 0.4, 0],
	},
    },

=head2 Example 4

Most commonly the defaults are adequate, but using the deeper options gives more control.  The following will give
an orange price mark outlined in black.

   shape => 'stock2',
   color => [0.5, 0.5, 0],
   width => 1,

This does essentially the same thing except the orange is now a narrow strip inside a dark blue border.
   
   price => {
       style => {
	   point => {
	       shape => 'stock2',
	       inner_color => [0.5, 0.5, 0],
	       outer_color => [0, 0, 0.6],
	       inner_width => 0.5,
	       outer_width => 2.5,
	   },
       },
   },

=cut

=head1 CONSTRUCTOR

=cut

sub new {
    my $class = shift;
    my $opt = {};
    if (@_ == 1) { $opt = $_[0]; } else { %$opt = @_; }
   
    my $o = {};
    bless( $o, $class );
  
    ## option hashes
    $o->{op}      = $opt->{price} || {};
    my $op        = $o->{op};
    $op->{layout} = {} unless (defined $op->{layout});
    $op->{x_axis} = {} unless (defined $op->{x_axis});
    $op->{y_axis} = {} unless (defined $op->{y_axis});
    $op->{style}  = {} unless (defined $op->{style});
    my $opl       = $op->{layout};
    my $opx       = $op->{x_axis};
    my $opy       = $op->{y_axis};
    my $ops       = $op->{style};
    $ops->{point} = {} unless (defined $ops->{point});
    my $opsp      = $ops->{point};
    
    $o->{ov}      = $opt->{volume} || {};
    my $ov        = $o->{ov};
    $ov->{layout} = {} unless (defined $ov->{layout});
    $ov->{x_axis} = {} unless (defined $ov->{x_axis});
    $ov->{y_axis} = {} unless (defined $ov->{y_axis});
    $ov->{style}  = {} unless (defined $ov->{style});
    my $ovl       = $ov->{layout};
    my $ovx       = $ov->{x_axis};
    my $ovy       = $ov->{y_axis};
    my $ovs       = $ov->{style};
    $ovs->{bar}   = {} unless (defined $ovs->{bar});
    my $ovsb      = $ovs->{bar};

    ## identify date options
    $o->{dtype} = defined($opt->{dates}) ? $opt->{dates} : "workdays";
    my $dtype = $o->{dtype};
    my ($dsdow, $dsday, $dsmonth, $dsyear);
    CASE: {
	if ($dtype eq 'days') {
	    ($dsdow, $dsday, $dsmonth, $dsyear) = (1, 1, 1, 0);
	    last CASE;
	}
	if ($dtype eq 'workdays') {
	    ($dsdow, $dsday, $dsmonth, $dsyear) = (1, 1, 1, 0);
	    last CASE;
	}
	if ($dtype eq 'weeks') {
	    ($dsdow, $dsday, $dsmonth, $dsyear) = (0, 1, 1, 0);
	    last CASE;
	}
	if ($dtype eq 'months') {
	    ($dsdow, $dsday, $dsmonth, $dsyear) = (0, 0, 1, 1);
	    last CASE;
	}
	# ($dtype eq 'data')
	    ($dsdow, $dsday, $dsmonth, $dsyear) = (0, 1, 1, 1);
    }
    $o->{dsday}   = defined($opt->{show_weekday}) ? $opt->{show_weekday}        : $dsdow;
    $o->{dsdate}  = defined($opt->{show_day})     ? $opt->{show_day}            : $dsday;
    $o->{dsmonth} = defined($opt->{show_month})   ? $opt->{show_month}          : $dsmonth;
    $o->{dsyear}  = defined($opt->{show_year})    ? $opt->{show_year}           : $dsyear;
    $o->{dsall}   = defined($opt->{changes_only}) ? ($opt->{changes_only} == 0) : 0;
    
    ## identify file options
    if (defined $opt->{file}) {
	$o->{of} = $opt->{file};
    }
    
    ## identify price/volume proportions
    $o->{pprice}    = $opt->{price_percent};
    $o->{pvolume}   = $opt->{volume_percent};
    unless (defined $o->{pprice}) {
	$o->{pprice} = $opt->{price}{percent} if (defined $opt->{price});
	$o->{pprice} = 75;
    }
    unless (defined $o->{pvolume}) {
	$o->{pvolume} = $opt->{volume}{percent} if (defined $opt->{volume});
	$o->{pvolume} = 25;
    }

    ## convenience options for both price and volume
    my $heading     = defined($opt->{heading})       ? $opt->{heading}       : "";
    my $title       = defined($opt->{price_title})   ? $opt->{price_title}   : "Price";
    my $bartitle    = defined($opt->{volume_title})  ? $opt->{volume_title}  : "Volume";
    my $background  = defined($opt->{background})    ? $opt->{background}    : 1;
    my $showlines   = defined($opt->{show_lines})    ? $opt->{show_lines}    : 0;
    my $color       = defined($opt->{color})         ? $opt->{color}         : 0;
    my $width       = defined($opt->{width})         ? $opt->{width}         : 1;
    my $shape       = defined($opt->{shape})         ? $opt->{shape}         : 'stock2';
    my $outlinesame = defined($opt->{bgnd_outline})  ? ($opt->{bgnd_outline} == 0) : 0;
    my $barcolor    = defined($opt->{bar_color})     ? $opt->{bar_color}     : $color;
    my $barwidth    = defined($opt->{bar_width})     ? $opt->{bar_width}     : 0.25;
    my $xheavycol   = defined($opt->{x_heavy_color}) ? $opt->{x_heavy_color} : 0.4;
    my $xmidcol     = defined($opt->{x_mid_color})   ? $opt->{x_mid_color}   : 0.5;
    my $xlightcol   = defined($opt->{x_light_color}) ? $opt->{x_light_color} : undef;
    my $yheavycol   = defined($opt->{y_heavy_color}) ? $opt->{y_heavy_color} : 0.4;
    my $ymidcol     = defined($opt->{y_mid_color})   ? $opt->{y_mid_color}   : 0.5;
    my $ylightcol   = defined($opt->{y_light_color}) ? $opt->{y_light_color} : 0.6;
    my $xheavywidth = defined($opt->{x_heavy_width}) ? $opt->{x_heavy_width} : 0.75;
    my $xmidwidth   = defined($opt->{x_mid_width})   ? $opt->{x_mid_width}   : 0.5;
    my $xlightwidth = defined($opt->{x_light_width}) ? $opt->{x_light_width} : 0.25;
    my $yheavywidth = defined($opt->{y_heavy_width}) ? $opt->{y_heavy_width} : 0.75;
    my $ymidwidth   = defined($opt->{y_mid_width})   ? $opt->{y_mid_width}   : 0.5;
    my $ylightwidth = defined($opt->{y_light_width}) ? $opt->{y_light_width} : 0.25;

    my @days   = qw(- Mon Tue Wed Thu Fri Sat Sun);
    my @months = qw(- Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec);
    $o->{dname}     = defined($opt->{days})          ? $opt->{days}          : \@days;
    $o->{mname}     = defined($opt->{months})        ? $opt->{months}        : \@months;
    
    ## identify price options
    if ($o->{pprice}) {
	$ops->{auto}        = "none";
	$ops->{same}        = $outlinesame unless (defined $ops->{same});
	$opsp->{color}      = $color       unless (defined $opsp->{color});
	$opsp->{width}      = $width       unless (defined $opsp->{width});
	$opsp->{shape}      = $shape       unless (defined $opsp->{shape});
	$opl->{heading}     = $heading     unless (defined $opl->{heading});
	$opl->{background}  = $background  unless (defined $opl->{background});
	$opx->{show_lines}  = $showlines   unless (defined $opx->{show_lines});
	$opx->{heavy_color} = $xheavycol   unless (defined $opx->{heavy_color});
	$opx->{mid_color}   = $xmidcol     unless (defined $opx->{mid_color});
	$opx->{light_color} = $xlightcol   unless (defined $opx->{light_color});
	$opy->{title}       = $title       unless (defined $opy->{title});
	$opy->{heavy_width} = $yheavywidth unless (defined $opy->{heavy_width});
	$opy->{mid_width}   = $ymidwidth   unless (defined $opy->{mid_width});
	$opy->{light_width} = $ylightwidth unless (defined $opy->{light_width});
    }
    
    ## identify volume options
    if ($o->{pvolume}) {
	$ovs->{auto}        = "none";
	$ovs->{same}        = $outlinesame unless (defined $ovs->{same});
	$ovsb->{color}      = $barcolor    unless (defined $ovsb->{color});
	$ovsb->{width}      = $barwidth    unless (defined $ovsb->{width});
	$ovl->{heading}     = $heading     unless (defined($ovl->{heading}) or $o->{pprice});
	$ovl->{background}  = $background  unless (defined $ovl->{background});
	$ovx->{show_lines}  = $showlines   unless (defined $ovx->{show_lines});
	$ovx->{heavy_color} = $xheavycol   unless (defined $ovx->{heavy_color});
	$ovx->{mid_color}   = $xmidcol     unless (defined $ovx->{mid_color});
	$ovx->{light_color} = $xlightcol   unless (defined $ovx->{light_color});
	$ovy->{title}       = $bartitle    unless (defined $ovy->{title});
	$ovy->{heavy_width} = $yheavywidth unless (defined $ovy->{heavy_width});
	$ovy->{mid_width}   = $ymidwidth   unless (defined $ovy->{mid_width});
	$ovy->{light_width} = $ylightwidth unless (defined $ovy->{light_width});
    }
  
    return $o;
}

=head2 new( [options ] )

C<options> can either be a list of hash keys and values or a hash reference.  In either case, the hash is expected
to have the same structure.  Some of the primary keys are simple values but a few point to sub-hashes which hold
options or groups themselves.

All color options can take either monochrome or colour format values.  If a single number from 0 to 1.0 inclusive,
this is interpreted as a shade of grey, with 0 being black and 1 being white.  Alternatively an array ref holding
three such values is read as holding red, green and blue values - again 1 is the brightest possible value.

    Value	    Interpretation
    =====	    ==============
    0		    black
    0.5		    grey
    1		    white
    [1, 0, 0]	    red
    [0, 1, 0]	    green
    [0, 0, 1]       blue
    [1, 1, 0.9]	    light cream
    [0, 0.8, 0.6]   turquoise

Other numbers are floating point values in PostScript native units (72 per inch).
    
=head3 background

Fill colour for price and volume chart backgrounds.  (Default: 1)

Shortcut for price =>{ layout =>{ background => ... }} and/or volume =>{ layout =>{ background => ... }}.

=head3 bar_color

Sets the colour of the volume bars.  (Defaults to C<color>)

Shortcut for volume =>{ style =>{ point =>{ color => ... }}}.

=head3 bar_width

Sets the width of the volume bar outline.  (Defaults to C<width>)

Shortcut for volume =>{ style =>{ bar =>{ width => ... }}}.

=cut

=head3 bgnd_outline

By default shapes 'stock2' and 'close2' (see B<shape>) are outlined with the complementary colour to the
background, making them stand out.  Setting this to 1 makes the outline default to the background colour itself.
(Default: 0)

=head3 changes_only

The date labels are made up of weekday, day, month and year.  Which sections are shown by default depends on the
B<dates> setting.  If this is 1, each part is only shown if it has changed from the previous label.  If 0, all the
selected parts are shown.  (Default: 1)

=head3 color

Sets the colour of the price marks and/or volume bars.  (Default: 0)

Shortcut for price =>{ style =>{ point =>{ color => ... }}} and/or volume =>{ style =>{ bar =>{ color => ...
}}}.

=head3 dates

This string determines how the dates are distributed across the X axis.

=over 4

=item B<data>

The dates are those present in the CSV file, but in chronological order.

=item B<days>

Every day between the first and last day in the CSV file is listed, whether there is data for that day or not.

=item B<workdays>

Every day except Saturdays and Sundays.  Occasional holidays are ignored, just showing as days with no data.

=item B<weeks>

Only the data for last trading day of each week is presented.  No attempt is made to take the rest of the week
into account - those days are just hidden.   If any trading is recorded for that week, the latest day is given; if
not the last working day is shown, with no data.

=item B<months>

As weeks, but showing the last trading day of each month.

=head3 days

This allows the weekday abbreviations to be presented in a different language.  It should be an array ref
containing strings.  Monday = 1, so there should probably be a dummy string for 0.  (Defaults to English).

=head3 file

This may be either a PostScript::File object or a hash ref holding options for it. See
L<PostScript::File> for details.  Options within this group include the paper size, orientation, debugging
features and whether it is an EPS or a normal PostScript file.

Creating the PostScript::File object first has the advantage of allowing more than one chart to be printed
from the same document.

Example

    use PostScript::Graph::Stock;
    use PostScript::File;
    my $pgf = new PostScript::File();
    
    my $gs1 = new PostScript::Graph::Stock(
		    file => pgf,
		);
    $gs1->build_chart( 'stock1.csv' );
   
    $pgf->newpage();
    my $gs1 = new PostScript::Graph::Stock(
		    file => pgf,
		);
    $gs1->build_chart( 'stock2.csv' );
    
    $pgf->output( 'graph' );

=head3 heading

A string which appears centrally above the price chart (or the volume chart if there are no prices).  (Default:
'')

Shortcut for price =>{ layout =>{ heading => ... }} or volume =>{ layout =>{ heading => ... }}. 

=head3 months

This allows the month abbreviations to be presented in a different language.  It should be an array ref
containing strings.  January = 1, so there should probably be a dummy string for 0.  (Defaults to English).

=head3 price

This holds all the options pertaining to the price chart.  It is similar in structure to PostScript::Graph::XY
options with the following exceptions. 

=over 4

=item C<file>

The 'file' section is not used here but is a seperate top-level option.

=item C<style>

This section only controls the price points, so the 'line' and 'bar' subsections are not used. There is only one
PostScript::Graph::Style object used to show the price points, so 'sequence' and 'auto' are irrelevent too.  
    
=item C<chart>

There is no 'chart' group.  Settings specific to the stock graph are given to the constructor directly, at the top
level.

=back

See the manpage indicated for the details on what is relevant for each subsection.

    price => {
	layout => {
	    # General proportions, headings
	    # See PostScript::Graph::Paper
	},
	x_axis => {
	    # All settings for X axis
	    # See PostScript::Graph::Paper
	},
	y_axis => {
	    # All settings for Y axis
	    # See PostScript::Graph::Paper
	},
	style  => {
	    # Appearance of price points
	    # See PostScript::Graph::Style
	},
	key    => {
	    # Settings for Key area if there is one
	    # See PostScript::Graph::Key
	},
    },
    
=back

=head3 price_percent

The percentage of paper allocated to the price as opposed to the volume chart.  This is more of a 'rough
ratio' rather than a percentage, but it does give some control over the relative sizes.  The price_percent
value includes the date labels area whereas the volume_percent value does not.  

=head3 price_title

A string labelling the Y axis on the price chart.  (Default: '')

Shortcut for price =>{ y_axis =>{ title => ... }}.

=head3 show_day

Show the date of day within the month.  (Default: depends on C<dates>)

=head3 shape

Sets the shape of the price marks.  Suitable values are 'stock', 'stock2', 'close' and 'close2'. (Default: 'stock2')

The stock2 and close2 variants are drawn with inner and outer colours where the others are drawn just once using
the inner colour.

Shortcut for price =>{ style =>{ point =>{ shape => ... }}}.  Do NOT use the values normally available for point
shapes.  The postscript routines for 'dot', 'diamond' etc. require 2 parameters instead of the 5 used here.  Using
them would cause the code to fail unpredictably.  See L</POSTSCRIPT CODE> for further details.

=head3 show_lines

If 1, vertical lines are drawn on the charts.  0 means only horizontal graph lines are visible.  (Default: 0)

=head3 show_month

Show the month.  (Default: depends on C<dates>)

=head3 show_weekday

Show the day of the week.  (Default: depends on C<dates>)

=head3 show_year

Show the month.  (Default: depends on C<dates>)

=head3 volume

This holds all the options pertaining to the volume chart.  It is similar in structure to PostScript::Graph::Bar.
See B<price> for the structure and most of the exceptions.  Of course in the style section, it is 'bar' that is
relevant with 'point' and 'line' ignored.

=head3 volume_percent

The percentage of paper allocated to the volume as opposed to the price chart.  This is more of a 'rough
ratio' rather than a percentage, but it does give some control over the relative sizes.  The price_percent
value includes the date labels area whereas the volume_percent value does not.  

=head3 volume_title

A string labelling the Y axis on the volume chart.  (Default: '')

Shortcut for volume =>{ y_axis =>{ title => ... }}.

=head3 width

Sets the width of lines in the price marks.  (Default: 1.0)

Shortcut for price =>{ style =>{ point =>{ width => ... }}}.

=head3 x_heavy_color

The colour of the main vertical lines, if B<show_lines> is set.  (Default: 0.4)

Shortcut for price =>{ x_axis =>{ heavy_color => ... }} and/or volume =>{ x_axis =>{ heavy_color => ... }}.

=head3 x_heavy_width

The width of the main vertical lines, if B<show_lines> is set.  (Default: 0.75)

Shortcut for price =>{ x_axis =>{ heavy_width => ... }} and/or volume =>{ x_axis =>{ heavy_width => ... }}.

=head3 x_mid_color

If B<show_lines> is set and some date labels have been supressed, the unlabelled marks have lines of this colour.
(Default: 0.5)

Shortcut for price =>{ x_axis =>{ mid_color => ... }} and/or volume =>{ x_axis =>{ mid_color => ... }}.

=head3 x_mid_width

The width of I<mid> lines.  See B<x_mid_color>.  (Default: 0.5)

Shortcut for price =>{ x_axis =>{ mid_width => ... }} and/or volume =>{ x_axis =>{ mid_width => ... }}.

=head3 y_heavy_color

Colour of major (labelled) lines on the Y axis. (Default: 0.4)

Shortcut for price =>{ y_axis =>{ heavy_color => ... }} and/or volume =>{ y_axis =>{ heavy_color => ... }}.

=head3 y_heavy_width

Width of major (labelled) lines on the Y axis.  (Default: 0.75)

Shortcut for price =>{ y_axis =>{ heavy_width => ... }} and/or volume =>{ y_axis =>{ heavy_width => ... }}.

=head3 y_mid_color

Colour of intermediate (unlabelled) lines on the Y axis.  (Default: 0.5)

Shortcut for price =>{ y_axis =>{ mid_color => ... }} and/or volume =>{ y_axis =>{ mid_color => ... }}.

=head3 y_mid_width

Width of intermediate (unlabelled) lines on the Y axis.  (Default: 0.5)

Shortcut for price =>{ y_axis =>{ mid_width => ... }} and/or volume =>{ y_axis =>{ mid_width => ... }}.

=head3 y_light_color

Colour of lightest intermediate (unlabelled) lines on the Y axis.  (Default: 0.6)

Shortcut for price =>{ y_axis =>{ light_color => ... }} and/or volume =>{ y_axis =>{ light_color => ... }}.

=head3 y_light_width

Width of lightest intermediate (unlabelled) lines on the Y axis.  (Default: 0.25)

Shortcut for price =>{ y_axis =>{ light_width => ... }} and/or volume =>{ y_axis =>{ light_width => ... }}.

=head1 OBJECT METHODS

=cut

sub data_from_file {
    my ($o, $file, $dir) = @_;
    my $filename = check_file($file, $dir);
    my @data;
    my $csv = new Text::CSV_XS;
    open(INFILE, "<", $filename) or die "Unable to open \'$filename\': $!\nStopped";
    while (<INFILE>) {
	chomp;
	my $ok = $csv->parse($_);
	if ($ok) {
	    my @row = $csv->fields();
	    push @data, [ @row ] if (@row);
	}
    }
    close INFILE;

    $o->data_from_array( \@data );
}

=head2 data_from_file( file [, dir] )

=over 4

=item C<file>

An optional fully qualified path-and-file or a simple file name. If omitted, the special file
File::Spec->devnull() is returned.

=item C<dir>

An optional directory C<dir>.  If present (and C<file> is not already an absolute path), it is prepended to
C<file>.

=back

A CSV file is read and converted to price and/or volume data, as appropriate.  The comma seperated values are
interpreted by Text::CSV_XS and so are currently unable to tolerate white space.  See B<data_from_array> for
how the field contents are handled.

Any leading '~' is expanded to the users home directory.  If no absolute directory is given either as part of
C<file>, it is placed within the current directory.  B<File::Spec|File::Spec> is used throughout so file access
should be portable.  

=cut


sub data_from_array {
    my ($o, $data) = @_;
    die "Array required\nStopped" unless (defined $data);

    ## remove any headings
    my $number = qr/^\s*[-+]?[0-9.]+(?:[Ee][-+]?[0-9.]+)?\s*$/;
    unless ($data->[0][1] =~ $number) {
	my $row = shift(@$data);
    }

    ## prepare price and volume data
    my ($dfirst, $dlast, @first, @last);
    my ($pmin, $pmax, $vmin, $vmax);
    my (%price, %volume, %dates);
    foreach my $row (@$data) {
	my ($date, $open, $high, $low, $close, $volume) = @$row;
	$volume = $open unless (defined $close);
	my @ymd = ($date =~ /(\d{4})-(\d{2})-(\d{2})/);
	unless (@ymd) {
	    @ymd = Decode_Date_EU($date);
	    unless (@ymd) {
		@ymd = Decode_Date_US($date);
	    }
	    $date = string_from_ymd(@ymd) if (@ymd);
	}
	my ($year, $month, $day) = ymd_from_string($date);
	if (defined $day) {
	    $dates{$date}++;
	    my $d = Date_to_Days($year, $month, $day);
	    $dfirst = $d, @first = ($year, $month, $day) if (not defined($dfirst) or $d < $dfirst);
	    $dlast  = $d, @last  = ($year, $month, $day) if (not defined($dlast)  or $d > $dlast);
	}
	if (defined $close) {
	    $price{$date}  = [ $open, $high, $low, $close ];
	    $pmin = $open  if (not defined($pmin) or $open < $pmin);
	    $pmax = $high  if (not defined($pmax) or $high > $pmax);
	    $pmin = $low   if (not defined($pmin) or $low < $pmin);
	    $pmin = $close if (not defined($pmin) or $close < $pmin);
	}
	if (defined $volume) {
	    $volume{$date} = $volume;
	    $vmin = $volume if (not defined($vmin) or $volume < $vmin);
	    $vmax = $volume if (not defined($vmax) or $volume > $vmax);
	}
    }
    CASE: {
	if (not defined($pmin) and not defined($vmin)) {
	    die "No price or volume data\nStopped";
	}
	if (not defined($pmin) and     defined($vmin)) {
	    $o->{pprice} = 0; $o->{pvolume} = 1;
	    last CASE;
	}
	if (    defined($pmin) and not defined($vmin)) {
	    $o->{pprice} = 1; $o->{pvolume} = 0;
	    last CASE;
	}
	if (    defined($pmin) and     defined($vmin)) {
	    my $total = $o->{pprice} + $o->{pvolume};
	    $o->{pprice} = $o->{pprice}/$total;
	    $o->{pvolume} = $o->{pvolume}/$total;
	    last CASE;
	}
    }
    $o->{pmin}   = $pmin;
    $o->{pmax}   = $pmax;
    $o->{vmin}   = $vmin;
    $o->{vmax}   = $vmax;
    #print "pmin=$pmin, pmax=$pmax, vmin=$vmin, vmax=$vmax dfirst=$dfirst dlast=$dlast\n";
    
    ## determine number and type of labels
    my ($x, @labels, @order) = 0;   # $x is index into labels and order arrays
    my $dtype  = $o->{dtype};
    my ($endday, $endlabel, $enddate, $knownlabel, $knowndate) = (0);
    my @prev = (0, 0, 0);
    my $ldow = 0;
    my ($lday, $lmonth, $lyear) = @prev;
    my ($tdow, $tday, $tmonth, $tyear);
    my $ndays  = Delta_Days(@first, @last);
    my $labelmax = 0;
    for (my $i = 0; $i <= $ndays; $i++) {
	my @ymd     = Add_Delta_Days(@first, $i);
	my $dow     = Day_of_Week(@ymd);
	my $weekday = ($dow >= 1 and $dow <= 5);
	my $date    = string_from_ymd(@ymd);
	my $known   = $dates{$date};
	
	## construct label
	my ($year, $month, $day) = @ymd;
	my $label = "";
	$label .= $o->{dname}[$dow] . " "   if ($o->{dsday} and ($o->{dsall} or ($dow != $ldow)));
	$label .= $day . " "                if ($o->{dsdate} and ($o->{dsall} or ($day != $lday)));
	$label .= $o->{mname}[$month] . " " if ($o->{dsmonth} and ($o->{dsall} or ($month != $lmonth)));
	$label .= $year . " "               if ($o->{dsyear} and ($o->{dsall} or ($year != $lyear)));
	$label =~ s/\s+$//;
	$labelmax = length($label) if (length($label) > $labelmax);

	## select dates
	CASE: {
	    if ($dtype eq 'day') {
		if ($known) {
		    $dates{$date} = $x++; push @order, $date; push @labels, $label; 
		    $ldow=$dow; $lday=$day; $lmonth=$month; $lyear=$year;
		} else {
		    $dates{$date} = $x++; push @order, $date; push @labels, ""; 
		}
		$x++;
		last CASE;
	    }
	    if ($dtype eq 'workday') {
		if ($weekday) {
		    $dates{$date} = $x++; push @order, $date; push @labels, $label; 
		    $ldow=$dow; $lday=$day; $lmonth=$month; $lyear=$year;
		}
		last CASE;
	    }
	    if ($dtype eq 'week') {
		if ($weekday) {
		    if ($dow >= $endday) { 
			if ($known) {
			    $knowndate = $date; $knownlabel = $label;
			} else {
			    $enddate = $date; $endlabel = $label;
			}
			$tdow=$dow; $tday=$day; $tmonth=$month; $tyear=$year;
		    } else { 
			unless (defined $knowndate) { $knowndate = $enddate; $knownlabel = $endlabel; }
			unless (defined $enddate) { $enddate = $date; $endlabel = $label; } 
			$dates{$enddate} = $x++; push @order, $enddate; push @labels, $endlabel;
			$enddate = undef;
			$knowndate  = undef;
			$ldow=$tdow; $lday=$tday; $lmonth=$tmonth; $lyear=$tyear;
		    }
		    $endday = $dow;
		}
		last CASE;
	    }
	    if ($dtype eq 'month') {
		if ($weekday) {
		    if ($day >= $endday) {
			if ($known) {
			    $knowndate = $date; $knownlabel = $label;
			} else {
			    $enddate = $date; $endlabel = $label;
			}
			$tdow=$dow; $tday=$day; $tmonth=$month; $tyear=$year;
		    } else {
			unless (defined $knowndate) { $knowndate = $enddate; $knownlabel = $endlabel; }
			unless (defined $knowndate) { $knowndate = $date;    $knownlabel = $label; }
			$dates{$knowndate} = $x++; push @order, $knowndate; push @labels, $knownlabel;
			$enddate    = undef;
			$knowndate  = undef;
			$ldow=$tdow; $lday=$tday; $lmonth=$tmonth; $lyear=$tyear;
		    }
		    $endday = $day;
		}
		last CASE;
	    }
	    #  ($dtype eq 'data')
	    if ($known) {
		$dates{$date} = $x++; push @order, $date; push @labels, $label; 
		$ldow=$dow; $lday=$day; $lmonth=$month; $lyear=$year;
	    }
	}
    }

    ## finish off
    if (defined($knowndate) or defined($enddate)) {
	unless (defined $knowndate) { $knowndate = $enddate; $knownlabel = $endlabel; } 
	$dates{$knowndate} = $x++; push @order, $knowndate; push @labels, $knownlabel;
	$labelmax = length($knownlabel) if (length($knownlabel) > $labelmax);
    }
    $o->{dates}  = \%dates;
    $o->{labels} = \@labels;
    $o->{order}  = \@order;
    $o->{price}  = \%price;
    $o->{volume} = \%volume;
    $o->{lblmax} = $labelmax;
}
# $x is bar number, $date is key as given, $label is for printing
# $o->{labels}[$x]    == $label
# $o->{order}[$x]     == $date
# $o->{dates}{$date}  == $x
# $o->{price}{$date}  == [ $open, $high, $low, $close ]
# $o->{volume}{$date} == $volume
# price range is $o->{pmin} to $o->{pmax}
# volume range is $o->{vmin} to $o->{vmax}
# $o->{lblmax} is length of longest label

=head2 data_from_array( array_ref )

The array should be a list of array-refs, with each sub-array holding data for one day.  Three formats are
recognized:

    Date, Open, High, Low, Close, Volume
    Date, Open, High, Low, Close
    Date, Volume

Examples

    $pgs->data_from_array( [
	[2001-04-26, 345, 400, 300, 321, 12345678],
	[Apr-1-01, 234.56, 240.00, 230.00, 239.99],
	[13/4/01, 987654],
    ] );

The first field must be a date.  Attempts are made to recognize the format in turn:

=over 4

=item 1

The Finance::Shares::MySQL format is tried first, YYYY-MM-DD.

=item 2

European format dates are tried next using Date::Pcalc's Decode_Date_EU().

=item 3

Finally US dates are tried, picking up the !Yahoo format, Mar-01-99.

=back

The four price values are typically decimals and the volume is usually an integer in the millions.  These are used
to automatically calculate the vertical axes.

=cut

sub build_chart {
    my ($o, $arg) = @_;
    
    ## handle arg
    if (defined $arg) {
	if (ref($arg) =~ /ARRAY/) { 
	    $o->data_from_array($arg);
	} else {
	    $o->data_from_file($arg);
	}
    }
    die "No price data\nStopped" unless (defined($o->{labels}) and @{$o->{labels}});
    
    ## ensure there is a File object
    my $of   = $o->{of};
    if (ref($of) eq "PostScript::File") {
	$o->{pf} = $of;
    } else {
	$of->{left}   = 36 unless (defined $of->{left});
	$of->{right}  = 36 unless (defined $of->{right});
	$of->{top}    = 36 unless (defined $of->{top});
	$of->{bottom} = 36 unless (defined $of->{bottom});
	$of->{errors} = 1 unless (defined $of->{errors});
	$o->{pf}      = new PostScript::File( $of );
    }
    $o->ps_functions();

    ## option hashes
    my $op        = $o->{op};
    my $opl       = $op->{layout};
    my $opx       = $op->{x_axis};
    my $opy       = $op->{y_axis};
    my $ops       = $op->{style};
    my $opsp      = $ops->{point};
    my $ov        = $o->{ov};
    my $ovl       = $ov->{layout};
    my $ovx       = $ov->{x_axis};
    my $ovy       = $ov->{y_axis};
    my $ovs       = $ov->{style};
    my $ovsb      = $ovs->{bar};

    ## calculate height available
    my $fontsize;
    if ($o->{pprice}) {
	$fontsize = $opx->{font_size} || 10;
    } else {
	my $ovx = $o->{ov}{x_axis} || {};
	$fontsize = $ovx->{font_size} || 10;
    }
    my @pbox = $o->{pf}->get_page_bounding_box();
    my $label_height = $o->{lblmax} * 0.7 * $fontsize;
    my $height = $pbox[3] - $pbox[1] - $label_height;
    my $price_height = $height * $o->{pprice};
    my $volume_height = $height * $o->{pvolume};

    ## open dictionaries
    $o->{pf}->add_to_page( <<END_INIT );
	gpaperdict begin
	gstyledict begin
	gstockdict begin
END_INIT

   
    ## create price grid
    if ($o->{pprice}) {
	$op->{file}            = $o->{pf};
	$opl->{bottom_edge}    = $pbox[1] + $volume_height;
	$opl->{no_drawing}     = 1;
	$opx->{draw_fn}        = "xdrawstock";
	$opx->{labels}         = $o->{labels};
	$opx->{show_lines}     = 1 unless (defined $opx->{show_lines});
	$opx->{offset}         = 1;
	$opx->{sub_divisions}  = 2;
	$opx->{center}         = 0;
	$opx->{mark_max}       = 4 unless (defined $opx->{mark_max});
	$opx->{height}         = $label_height;
	$opy->{low}            = $o->{pmin};
	$opy->{high}           = $o->{pmax};
	$o->{pp}               = new PostScript::Graph::Paper( $op );
    }
    
    ## create volume grid
    if ($o->{pvolume}) {
	$ov->{file}                = $o->{pf};
	if ($o->{pprice}) {
	    $ovl->{top_edge}       = $pbox[3] - $price_height - $label_height;
	    $ovl->{heading_height} = 0 unless (defined $ovx->{heading_height});
	    $ovx->{mark_max}       = 0 unless (defined $ovx->{mark_max});
	    $ovx->{height}         = 5 unless (defined $ovx->{height});
	} else {
	    $ovl->{top_edge}       = $pbox[3] - $price_height;
	}
	$ovl->{no_drawing}     = 1;
	$ovx->{draw_fn}        = "xdrawstock";
	$ovx->{labels}         = $o->{labels};
	$ovx->{show_lines}     = $ov->{show_lines} if (defined $ov->{show_lines});
	$ovx->{show_lines}     = 1 unless (defined $ovx->{show_lines});
	$ovx->{offset}         = 1;
	$ovx->{sub_divisions}  = 2;
	$ovx->{center}         = 0;
	$ovy->{low}            = $o->{vmin};
	$ovy->{high}           = $o->{vmax};
	$ovy->{label_gap}      = 14;
	$o->{vp}               = new PostScript::Graph::Paper( $ov );
    }
    
    ## prepare labels within space available
    my $pp = $o->{pp};
    my $vp = $o->{vp};
    my $space = $pp ? $pp->x_axis_font_size()/2 : $vp->x_axis_font_size()/2;
    my $step  = $pp ? $pp->x_axis_mark_gap()    : $vp->x_axis_mark_gap();
    my $taken = $space;
    my $plabels = $o->{labels};
    my $vlabels = [];
    for (my $x = 0; $x <= $#$plabels; $x++) {
	$taken += $step;
	if ($taken < $space) {
	    $plabels->[$x] = "()";
	    push @$vlabels, "()";
	} else {
	    $taken = 0;
	    $plabels->[$x] = "( $plabels->[$x])";
	    push @$vlabels, "( )";
	}
    }
    if ($o->{pprice}) {
	$pp->x_axis_labels( $plabels );
	$pp->draw_scales();
    }
    if ($o->{pvolume}) {
	if ($o->{pprice}) {
	    $vp->x_axis_labels( $vlabels );
	} else {
	    $vp->x_axis_labels( $plabels );
	}
	$vp->draw_scales();
    }

    ## add price marks
    if ($o->{pprice}) {
	my $pstyle = new PostScript::Graph::Style( $ops );
	$pstyle->background( $o->{pp}->layout_background() );
	$pstyle->write( $o->{pf} );
	my $order  = $o->{order};
	my $prices = $o->{price};
	my $gp     = $o->{pp};
	for (my $x = 0; $x <= $#{$o->{labels}}; $x++) {
	    my $psx    = $gp->px( $x );
	    my $date   = $order->[$x];
	    my $price  = $prices->{$date};
	    if (defined $price) {
		my $yopen  = $gp->py( $price->[0] );
		my $yhigh  = $gp->py( $price->[1] );
		my $ylow   = $gp->py( $price->[2] );
		my $yclose = $gp->py( $price->[3] );
		$gp->add_to_page("$psx $yopen $ylow $yhigh $yclose ppshape\n");
	    }
	}
    }

    ## add volume bars
    if ($o->{pvolume}) {
	$ovs->{auto}   = "none";
	my $vstyle = new PostScript::Graph::Style( $ovs );
	$vstyle->background( $o->{vp}->layout_background() );
	$vstyle->write( $o->{pf} );
	my $vols  = $o->{volume};
	my $order = $o->{order};
	for (my $x = 0; $x <= $#{$o->{labels}}; $x++) {
	    my $date   = $order->[$x];
	    my $y      = $vols->{$date};
	    if (defined $y) {
		my @bb     = $o->{vp}->vertical_bar_area($x * 2, $y);
		my $lwidth = $vstyle->bar_outer_width()/2;
		$bb[0] += $lwidth;
		$bb[1] += $lwidth;
		$bb[2] -= $lwidth;
		$bb[3] -= $lwidth;
		$bb[3] = $bb[1] if ($bb[3] < $bb[1]);
		$o->{pf}->add_to_page( <<END_BAR );
		    $bb[0] $bb[1] $bb[2] $bb[3] bocolor bowidth drawbox
		    $bb[0] $bb[1] $bb[2] $bb[3] bicolor bicolor biwidth fillbox
END_BAR
	    }
	}
    }

    ## close dictionaries
    $o->{pf}->add_to_page( "end end end\n" );
}
# All chart options must be given to new()

=head2 build_chart( [array_ref | file [, dir]] )

This is the heart of the class which constructs the charts and produces the postscript code to draw them.  If an
array_ref is passed as the argument, this is given to B<data_from_array>.  Any other arguments are passed to
B<data_from_file>.  These are just for convenience.  B<build_chart> itself requires that the necessary options have
been given to B<new> and that it has some stock data to work on.

=cut

sub file {
    return shift()->{pf};
}

=head3 file

Return the underlying PostScript::File object.

=cut

sub output {
    shift()->{pf}->output(@_);
}

=head3 output( file [, dir] )

A convenience function to output the chart as a file.  See L<PostScript::File/output>.

=cut

=head1 POSTSCRIPT CODE

=cut

sub ps_functions {
    my $o = shift;

    my $name = "StockChart";
    $o->{pf}->add_function( $name, <<END_FUNCTIONS ) unless ($o->{pf}->has_function($name));
	/gstockdict 20 dict def
	gstockdict begin

	/make_stock {
	    gsave
		point_inner
		stockmark
	    grestore
	}bind def
	% x yopen ylow yhigh yclose => _

	/make_stock2 {
	    5 copy
	    gsave point_outer stockmark grestore
	    gsave point_inner stockmark grestore
	}bind def
	% x yopen ylow yhigh yclose => _
	
	/stockmark {
	    gpaperdict begin
	    gstockdict begin
		/yclose exch def
		/yhigh exch def
		/ylow exch def
		/yopen exch def
		/x exch xmarkgap add def
		/dx xmarkgap powidth 2 div sub def
		2 setlinecap
		newpath
		x dx sub yopen moveto
		x yopen lineto
		x ylow lineto
		0 0 rmoveto
		x yhigh lineto
		0 0 rmoveto
		x yclose lineto
		x dx add yclose lineto
		stroke
	    end end
	} bind def
	% x yopen ylow yhigh yclose => _

	/make_close {
	    gsave
		point_inner
		closemark
	    grestore
	}bind def
	% x yopen ylow yhigh yclose => _

	/make_close2 {
	    5 copy
	    gsave point_outer closemark grestore
	    gsave point_inner closemark grestore
	}bind def
	% x yopen ylow yhigh yclose => _
	
	/closemark {
	    gpaperdict begin
	    gstockdict begin
		/yclose exch def
		/yhigh exch def
		/ylow exch def
		/yopen exch def
		/x exch xmarkgap add def
		/dx xmarkgap powidth 2 div sub def
		2 setlinecap
		newpath
		x yclose moveto
		x dx add yclose lineto
		stroke
	    end end
	} bind def
	% x yopen ylow yhigh yclose => _

	end % stockdict
END_FUNCTIONS

}

=head2 gstockdict

A few functions are defined in the B<gstockdict> dictionary.  These provide the code for the shapes drawn as price
marks.  Of the 20 dictionary entries, 12 are defined, so there is room for a few more marks to be added
externally.

    make_stock	Draw single price mark
    make_stock2 Draw double price mark
    make_close	Draw single closing price mark
    make_close2 Draw double closing price mark
    yclose	parameter
    ylow	parameter
    yhigh	parameter
    yopen	parameter
    x		parameter
    dx		working value

A postscript function suitable for passing to the C<shape> option to B<new> must have 'make_' preprended to the
name.  It should take 5 parameters similar to the code for C<shape => 'stock'> which is called as follows.

    x yopen ylow yhigh yclose make_stock
    
=cut

1;

sub ymd_from_string {
    my $date = shift;
    return ($date =~ /(\d{4})-(\d{2})-(\d{2})/);
}

sub string_from_ymd {
    return sprintf("%04d-%02d-%02d", @_);
}

1;
