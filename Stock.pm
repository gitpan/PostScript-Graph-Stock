package PostScript::Graph::Stock;
use strict;
use warnings;
require Exporter;
use Text::CSV_XS;
use Date::Pcalc qw(:all);
use PostScript::File qw(check_file);
use PostScript::Graph::Key;
use PostScript::Graph::Paper;
use PostScript::Graph::Style;
use PostScript::Graph::XY;
use Finance::Shares::Sample;

our $VERSION = '0.051';

=head1 NAME

PostScript::Graph::Stock - draw share price graph from CSV data

=head1 SYNOPSIS

=head2 Simplest

Take a CSV file such as that produced by !Yahoo Finance websites (called 'stock_prices.csv' here), draw a graph
showing the price and volume data and output as a postscript file for printing ('graph.ps' in this example).

    use PostScript::Graph::Stock;

    my $pgs = new PostScript::Graph::Stock(
	    source => 'stock_prices.csv'
	);
    $pgs->output( 'graph' );

=head2 Typical

A number of settings are provided to configure the graph's appearance, adding colour for example.  The ability to
add analysis lines to either chart is planned.

    use PostScript::Graph::Stock;

    my $pgs = new PostScript::Graph::Stock(
	source		 => 'stock-prices.csv',
	heading          => 'MyCompany Shares',
	background       => [1, 1, 0.9],
	show_lines       => 1,
	
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

	dates => {
	    days         => [qw(- Mon Dien Mitt ...)],
	    months       => [qw(- Jan Feb Mars ...)],
	    by		 => 'weeks',
	    changes_only => 1,
	    show_weekday => 1,
	    show_day     => 1,
	    show_month   => 1,
	    show_year    => 1,
	},
	
	color          => [1, 0, 0],
	width          => 1.5,
	shape          => 'close2',
	bgnd_outline   => 1,
	bar_color      => [0.8, 0.4, 0.15],
	bar_width      => 0.5,

	price => {
	    percent      => 75,
	    title        => 'Price in pence',
	},

	volume => {
	    percent	 => 25,
	    title        => 'Transaction volume',
	},

	analysis => {
	    percent	 => 25,
	    low		 => -20,
	    high	 => 35,
	},
    );
    
    $pgs->output( 'graph' );

=head2 All options

Although a number of options are provided for convenience (see L</"Typical">), many of these are merely
a selection of the options which can be given to the underlying objects.  See the manpages for the options
available in each of the modules mentioned.

    use PostScript::Graph::Stock;

    my $pgs = new PostScript::Graph::Stock(
	source => ...
	
	file   => {
	    # for PostScript::File
	},
	dates  => {
	    # as 'Typical' above
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
	    # as 'price' above
	},

	analysis => {
	    # options for Analysis chart
	    # as 'price' above
	},
    );
    
    # build data and style structures
    $pgs->add_price_line( $data1, $style1, 'One');
    $pgs->add_analysis_line( $data2, $style2, 'Two');
    $pgs->add_volume_line( $data3, $style3, 'Three');
    
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

Options given to the constructor control the appearance of the chart.  The data can be given as a CSV file, an
array or a Finance::Shares::Sample object.  There are three areas to the chart: prices, volumes and analysis.
Lines may be drawn over the data on each area.  The chart is saved to a postscript file with the C<output>
function.  This file can be either a printable *.ps file or an Encapsulated PostScript file for inclusion
elsewhere.

The data is displayed as seperate charts showing price and volume.  These only appear if there is suitable data:
only a price chart is shown if the file has no volume data.  The proportion of space allocated for each is
configurable.  A Key is shown at the right of the relevant graph when analysis lines are added.

Theoretically, many years' worth of quotes can be accomodated, although the processing time becomes increasingly
obvious.  The output device tends to impose a practical limit, however.  For example, around 1000 vertical lines
can be distinguished on an A4 landscape sheet at 300dpi - 3 years of data at a pinch.  But it gets difficult to
read beyond 6-9 months.  To help with this, it is possible to simplify the output.

=head2 Example 1

To show only the closing values for the last day of each week, use these options:

   dates => {
       by => 'weeks',
   },
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

=head2 Methods Available

B<add_price_line>, B<add_analysis_line> and B<add_volume_line> provide ways of superimposing trend lines on the
price, analysis and volume charts.  The underlying PostScript::Graph::Paper objects are also available for adding
shaded areas, for example.

Once the data has been assembled the graph needs to be converted into PostScript code which does the actual drawing.
The simplest way is just to call B<output> which builds and saves the file in one go.  

Alternatively, several stock graphs may be output to the same PostScript file (on seperate pages).  When each
graph is ready B<build_graph> is called instead of 'output'.  Finally a call to B<output> saves the multi-page
document ready for viewing or printing.

=cut

=head1 CONSTRUCTOR

=cut

sub new {
    my $class = shift;
    my $opt = {};
    if (@_ == 1) { $opt = $_[0]; } else { %$opt = @_; }
   
    my $o = {};
    bless( $o, $class );
    $o->{plines} = [];
    $o->{vlines} = [];
    $o->{alines} = [];
    $o->{scount} = 0;
  
    ## option hashes
    $opt->{dates} = {}	unless defined $opt->{dates};
    $o->{od}	  = $opt->{dates};
    $o->{dtype}   = defined($o->{dates}{by}) ? $o->{dates}{by} : $opt->{dates_by} || 'data';
    $o->{epic}	  = $opt->{epic} || '<unknown>';
    
    $o->{op}      = $opt->{price} || {};
    my $op        = $o->{op};
    $op->{layout} = {} unless (defined $op->{layout});
    $op->{x_axis} = {} unless (defined $op->{x_axis});
    $op->{y_axis} = {} unless (defined $op->{y_axis});
    $op->{style}  = {} unless (defined $op->{style});
    $op->{key}    = {} unless (defined $op->{key});
    my $opl       = $op->{layout};
    my $opx       = $op->{x_axis};
    my $opy       = $op->{y_axis};
    my $ops       = $op->{style};
    my $opk       = $op->{key};
    $ops->{point} = {} unless (defined $ops->{point});
    my $opsp      = $ops->{point};
    
    $o->{oa}      = $opt->{analysis} || {};
    my $oa        = $o->{oa};
    $oa->{layout} = {} unless (defined $oa->{layout});
    $oa->{x_axis} = {} unless (defined $oa->{x_axis});
    $oa->{y_axis} = {} unless (defined $oa->{y_axis});
    $oa->{key}    = {} unless (defined $oa->{key});
    my $oal       = $oa->{layout};
    my $oax       = $oa->{x_axis};
    my $oay       = $oa->{y_axis};
    my $oak       = $oa->{key};
    
    $o->{ov}      = $opt->{volume} || {};
    my $ov        = $o->{ov};
    $ov->{layout} = {} unless (defined $ov->{layout});
    $ov->{x_axis} = {} unless (defined $ov->{x_axis});
    $ov->{y_axis} = {} unless (defined $ov->{y_axis});
    $ov->{style}  = {} unless (defined $ov->{style});
    $ov->{key}    = {} unless (defined $ov->{key});
    my $ovl       = $ov->{layout};
    my $ovx       = $ov->{x_axis};
    my $ovy       = $ov->{y_axis};
    my $ovs       = $ov->{style};
    my $ovk       = $ov->{key};
    $ovs->{bar}   = {} unless (defined $ovs->{bar});
    my $ovsb      = $ovs->{bar};

    ## chart proportions
    $o->{pprice}  = $op->{percent} || 75;
    $o->{panal}   = $oa->{percent} || 0 ;
    $o->{pvolume} = $ov->{percent} || 25;
    my $total       = $o->{pprice} + $o->{panal} + $o->{pvolume};
    $o->{pprice}   /= $total;
    $o->{panal}    /= $total;
    $o->{pvolume}  /= $total;
    
    ## convenience options
    my $smallest    = defined($opt->{smallest})	     ? $opt->{smallest}	     : undef;
    my $heading     = defined($opt->{heading})       ? $opt->{heading}       : "";
    my $background  = defined($opt->{background})    ? $opt->{background}    : 1;
    my $showlines   = defined($opt->{show_lines})    ? $opt->{show_lines}    : 0;
    my $color       = defined($opt->{color})         ? $opt->{color}         : undef;
    my $width       = defined($opt->{width})         ? $opt->{width}         : undef;
    my $shape       = defined($opt->{shape})         ? $opt->{shape}         : undef;
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
    my $glyph_ratio = defined($opt->{glyph_ratio})   ? $opt->{glyph_ratio}   : 0.47;
    
    $o->{key}	    = defined($opt->{show_key})	     ? $opt->{show_key}	     : 1;

    ## identify price options
    if ($o->{pprice}) {
	$ops->{auto}        = "none";
	$ops->{same}        = $outlinesame unless (defined $ops->{same});
	$opsp->{color}      = $color       unless (defined $opsp->{color});
	$opsp->{width}      = $width       unless (defined $opsp->{width});
	$opsp->{shape}      = $shape || 'stock2' unless (defined $opsp->{shape});
	$opk->{glyph_ratio} = $glyph_ratio unless (defined $opk->{glyph_ratio});
	$opl->{heading}     = $heading     unless (defined $opl->{heading});
	$opl->{background}  = $background  unless (defined $opl->{background});
	$opx->{smallest}    = $smallest    unless (defined $opx->{smallest});
	$opx->{show_lines}  = $showlines   unless (defined $opx->{show_lines});
	$opx->{heavy_color} = $xheavycol   unless (defined $opx->{heavy_color});
	$opx->{mid_color}   = $xmidcol     unless (defined $opx->{mid_color});
	$opx->{light_color} = $xlightcol   unless (defined $opx->{light_color});
	$opy->{smallest}    = $smallest    unless (defined $opy->{smallest});
	$opy->{heavy_width} = $yheavywidth unless (defined $opy->{heavy_width});
	$opy->{mid_width}   = $ymidwidth   unless (defined $opy->{mid_width});
	$opy->{light_width} = $ylightwidth unless (defined $opy->{light_width});
	$opy->{title}       = $op->{title} || "Price";
    }
    
    ## identify analysis options
    if ($o->{panal}) {
	$oak->{glyph_ratio} = $glyph_ratio unless (defined $oak->{glyph_ratio});
	$oal->{heading}     = $heading     unless (defined($oal->{heading}) or $o->{pprice});
	$oal->{background}  = $background  unless (defined $oal->{background});
	$oax->{smallest}    = $smallest    unless (defined $oax->{smallest});
	$oax->{show_lines}  = $showlines   unless (defined $oax->{show_lines});
	$oax->{heavy_color} = $xheavycol   unless (defined $oax->{heavy_color});
	$oax->{mid_color}   = $xmidcol     unless (defined $oax->{mid_color});
	$oax->{light_color} = $xlightcol   unless (defined $oax->{light_color});
	$oay->{smallest}    = $smallest    unless (defined $oay->{smallest});
	$oay->{heavy_width} = $yheavywidth unless (defined $oay->{heavy_width});
	$oay->{mid_width}   = $ymidwidth   unless (defined $oay->{mid_width});
	$oay->{light_width} = $ylightwidth unless (defined $oay->{light_width});
	$oay->{low}         = $oa->{low};
	$oay->{high}        = $oa->{high};
	$oay->{title}       = $oa->{title} || "Analysis";
    }
     ## identify volume options
    if ($o->{pvolume}) {
	$ovs->{auto}        = "none";
	$ovs->{same}        = $outlinesame unless (defined $ovs->{same});
	$ovsb->{color}      = $barcolor    unless (defined $ovsb->{color});
	$ovsb->{width}      = $barwidth    unless (defined $ovsb->{width});
	$ovk->{glyph_ratio} = $glyph_ratio unless (defined $ovk->{glyph_ratio});
	$ovl->{heading}     = $heading     unless (defined($ovl->{heading}) or $o->{pprice} or $o->{panal});
	$ovl->{background}  = $background  unless (defined $ovl->{background});
	$ovx->{smallest}    = $smallest    unless (defined $ovx->{smallest});
	$ovx->{show_lines}  = $showlines   unless (defined $ovx->{show_lines});
	$ovx->{heavy_color} = $xheavycol   unless (defined $ovx->{heavy_color});
	$ovx->{mid_color}   = $xmidcol     unless (defined $ovx->{mid_color});
	$ovx->{light_color} = $xlightcol   unless (defined $ovx->{light_color});
	$ovy->{smallest}    = $smallest    unless (defined $ovy->{smallest});
	$ovy->{heavy_width} = $yheavywidth unless (defined $ovy->{heavy_width});
	$ovy->{mid_width}   = $ymidwidth   unless (defined $ovy->{mid_width});
	$ovy->{light_width} = $ylightwidth unless (defined $ovy->{light_width});
	$ovy->{title}       = $ov->{title} || "Volume";
    }
  
    ## global file/data options
    $o->{of}      = $opt->{file};
    $o->from_sample($opt->{sample}) if (defined $opt->{sample});
    $o->from_array($opt->{array})   if (defined($opt->{array}) and not $o->{sample});
    $o->from_csv($opt->{csv})       if (defined($opt->{csv}) and not $o->{sample});
    
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

Some additional fields in each of the chart areas are specific to this module.  C<price>, C<volume> and C<analysis>
may have the following in addition to the normal PostScript::Graph::Paper, PostScript::Graph::Key and
PostScript::Graph::Style options.

=over 4

=item B<glyph_ratio>

The proportion of key font size to count as the width of one character.  (Default: 0.45)

There is no way to calculate the width the actual key text will take up, but some estimate is needed when working
out the width of the Key box.  This factor allows the user to fine-tune this guess if the text doesn't fit well.

    Shortcut for:
    key =>{ glyph_ratio => ... }

=item B<high>

For analysis chart only.  Top of Y axis on the analysis graph.  (Default: undefined)

    Shortcut for:
    y_axis =>{ high => ... }

=item B<low>

For analysis chart only.  Bottom of Y axis on the analysis graph.  (Default: undefined)

    Shortcut for:
    y_axis =>{ low => ... }

=item B<percent>

Set the proportion of space allocated to this chart.  See e.g. C<price_percent>.

=item B<sequence>

If present, this should be a PostScript::Graph::Sequence object.  This controls any styles automatically generated
for lines added to this chart.

=item B<title>

A string labelling the Y axis of this chart.

    Shortcut for:
    y_axis =>{ title => ... }

=back
   
The following are recognized top-level options.  They are mostly shortcuts of frequently used deeper options.

=head3 analysis

A sub-hash holding all settings for the analysis chart.  See C<price> below for most of the details.  The
exception is that the 'style' sub-hash is ignored as no data is presented here.  

This graph is provided for adding momentum analysis or other lines that don't use price or volume scales.  At
present only one analysis graph is possible, so the Y axis must be chosen to accomodate all the required lines.

=head3 array

One of three ways to enter stock price and/or volume data, the others being C<csv> and C<sample>.

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

The four price values are typically decimals and the volume is usually an integer in the millions.  If the option
C<dates> is I<weeks> the average price and volume data for the week is given under the last known day.  Average
prices are also calculated for I<months>.

=cut

=head3 background

Fill colour for price and volume chart backgrounds.  (Default: 1)

    Shortcut for:
    price =>{ layout =>{ background => ... }}
    volume =>{ layout =>{ background => ... }}

=head3 bar_color

Sets the colour of the volume bars.  (Defaults to C<color>)

    Shortcut for:
    volume =>{ style =>{ point =>{ color => ... }}}

=head3 bar_width

Sets the width of the volume bar outline.  (Defaults to C<width>)

    Shortcut for:
    volume =>{ style =>{ bar =>{ width => ... }}}

=cut

=head3 bgnd_outline

By default shapes 'stock2' and 'close2' (see B<shape>) are outlined with the complementary colour to the
background, making them stand out.  Setting this to 1 makes the outline default to the background colour itself.
(Default: 0)

    Shortcut for:
    price =>{ style =>{ same => (not ...) }}
    volume =>{ style =>{ same => (not ...) }}
    
=head3 color

Sets the colour of the price marks and/or volume bars.  (Default: 0)

    Shortcut for:
    price =>{ style =>{ point =>{ color => ... }}}
    volume =>{ style =>{ bar =>{ color => ... }}}

=head3 csv

One of three ways to enter stock price and/or volume data, the others being C<array> and C<sample>.

This should be the name of a comma seperated value (CSV) file with fields in one of the following formats.
A heading line is optional.

    Date,Volume
    Date,Open,High,Low,Close
    Date,Open,High,Low,Close,Volume

!Yahoo Finance provide a suitable source of files in the right format.  If that is what you want you might
like to look at L<Finance::Shares::MySQL> and L<Finance::Shares::Sample>.

The CSV file is read and converted to price and/or volume data, as appropriate.  The comma seperated values are
interpreted by Text::CSV_XS and so are currently unable to tolerate white space.  See the C<array> option for
how the field contents are handled.

=head3 dates

This is a sub-hash controlling how the X axis is laid out.  See L<prepare_dates> for details.

Example

    my $ss = new PostScript::Graph::Stock(
		dates => {
		    by => 'weeks',
		},
	    );

Not really a shortcut for any specific price or volume settings, but a replacement for various x_axis values.

=head3 dates_by

The equivalent to C<dates =>{ by => ... }>, this shortcut is included because it almost always needs specifying.

=head3 epic

The exchange code of the stock being charted.

=head3 file

This may be either a PostScript::File object or a hash ref holding options for it. See
L<PostScript::File> for details.  Options within this group include the paper size, orientation, debugging
features and whether it is an EPS or a normal PostScript file.

Creating the PostScript::File object first has the advantage of allowing more than one chart to be printed
from the same document.  See L<build_graph>.

=head3 glyph_ratio

The proportion of key font size to count as the width of one character.  (Default: 0.45)

There is no way to calculate the width the actual key text will take up, but some estimate is needed when working
out the width of the Key box.  This factor allows the user to fine-tune this guess if the text doesn't fit well.

    Shortcut for:
    price =>{ key =>{ glyph_ratio => ... }}
    volume =>{ key =>{ glyph_ratio => ... }}
    analysis =>{ key =>{ glyph_ratio => ... }}


=head3 heading

A string which appears centrally above the top chart.  (Default: '')

    Shortcut for:
    price =>{ layout =>{ heading => ... }}
    analysis =>{ layout =>{ heading => ... }}
    volume =>{ layout =>{ heading => ... }}

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
    
=head3 sample

One of three ways to enter stock price and/or volume data, the others being C<array> and C<csv>.  This should be
a Finance::Shares::Sample object already filled with suitable data.

=head3 shape

Sets the shape of the price marks.  Suitable values are 'stock', 'stock2', 'close' and 'close2'. (Default: 'stock2')

The stock2 and close2 variants are drawn with inner and outer colours where the others are drawn just once using
the inner colour.

Shortcut for price =>{ style =>{ point =>{ shape => ... }}}.  Do NOT use the values normally available for point
shapes.  The postscript routines for 'dot', 'diamond' etc. require 2 parameters instead of the 5 used here.  Using
them would cause the code to fail unpredictably.  See L</POSTSCRIPT CODE> for further details.

    Shortcut for:
    price =>{ style =>{ point =>{ shape => ... }}}

=head3 show_key

Set to 0 to hide the Key boxes that appear on the left when lines are added over the data.  (Default: 1)

=head3 show_lines

If 1, vertical lines are drawn on the charts.  0 means only horizontal graph lines are visible.  (Default: 0)

    Shortcut for:
    price =>{ x_axis =>{ show_lines => ... }}
    analysis =>{ x_axis =>{ show_lines => ... }}
    volume =>{ x_axis =>{ show_lines => ... }}

=head3 smallest

This is the granularity of the axes.  Setting it to a larger value reduces the number of axis marks.  (The default
depends upon the value given to file =>{ dpi => ... })

    Shortcut for
    price =>{ x_axis =>{ smallest => ... }}
    price =>{ y_axis =>{ smallest => ... }}
    analysis =>{ x_axis =>{ smallest => ... }}
    analysis =>{ y_axis =>{ smallest => ... }}
    volume =>{ x_axis =>{ smallest => ... }}
    volume =>{ y_axis =>{ smallest => ... }}

=head3 volume

This holds all the options pertaining to the volume chart.  It is similar in structure to PostScript::Graph::Bar.
See B<price> for the structure and most of the exceptions.  Of course in the style section, it is 'bar' that is
relevant with 'point' and 'line' ignored.

=head3 width

Sets the width of lines in the price marks.  (Default: 1.0)

    Shortcut for:
    price =>{ style =>{ point =>{ width => ... }}}

=head3 x_heavy_color

The colour of the main vertical lines, if B<show_lines> is set.  (Default: 0.4)

    Shortcut for:
    price =>{ x_axis =>{ heavy_color => ... }}
    analysis =>{ x_axis =>{ heavy_color => ... }}
    volume =>{ x_axis =>{ heavy_color => ... }}

=head3 x_heavy_width

The width of the main vertical lines, if B<show_lines> is set.  (Default: 0.75)

    Shortcut for:
    price =>{ x_axis =>{ heavy_width => ... }}
    analysis =>{ x_axis =>{ heavy_width => ... }}
    volume =>{ x_axis =>{ heavy_width => ... }}

=head3 x_mid_color

If B<show_lines> is set and some date labels have been supressed, the unlabelled marks have lines of this colour.
(Default: 0.5)

    Shortcut for:
    price =>{ x_axis =>{ mid_color => ... }}
    analysis =>{ x_axis =>{ mid_color => ... }}
    volume =>{ x_axis =>{ mid_color => ... }}

=head3 x_mid_width

The width of I<mid> lines.  See B<x_mid_color>.  (Default: 0.5)

    Shortcut for:
    price =>{ x_axis =>{ mid_width => ... }}
    analysis =>{ x_axis =>{ mid_width => ... }}
    volume =>{ x_axis =>{ mid_width => ... }}

=head3 y_heavy_color

Colour of major (labelled) lines on the Y axis. (Default: 0.4)

    Shortcut for:
    price =>{ y_axis =>{ heavy_color => ... }}
    analysis =>{ y_axis =>{ heavy_color => ... }}
    volume =>{ y_axis =>{ heavy_color => ... }}

=head3 y_heavy_width

Width of major (labelled) lines on the Y axis.  (Default: 0.75)

    Shortcut for:
    price =>{ y_axis =>{ heavy_width => ... }}
    analysis =>{ y_axis =>{ heavy_width => ... }}
    volume =>{ y_axis =>{ heavy_width => ... }}

=head3 y_mid_color

Colour of intermediate (unlabelled) lines on the Y axis.  (Default: 0.5)

    Shortcut for:
    price =>{ y_axis =>{ mid_color => ... }}
    analysis =>{ y_axis =>{ mid_color => ... }}
    volume =>{ y_axis =>{ mid_color => ... }}

=head3 y_mid_width

Width of intermediate (unlabelled) lines on the Y axis.  (Default: 0.5)

    Shortcut for:
    price =>{ y_axis =>{ mid_width => ... }}
    analysis =>{ y_axis =>{ mid_width => ... }}
    volume =>{ y_axis =>{ mid_width => ... }}

=head3 y_light_color

Colour of lightest intermediate (unlabelled) lines on the Y axis.  (Default: 0.6)

    Shortcut for:
    price =>{ y_axis =>{ light_color => ... }}
    analysis =>{ y_axis =>{ light_color => ... }}
    volume =>{ y_axis =>{ light_color => ... }}

=head3 y_light_width

Width of lightest intermediate (unlabelled) lines on the Y axis.  (Default: 0.25)

    Shortcut for:
    price =>{ y_axis =>{ light_width => ... }}
    analysis =>{ y_axis =>{ light_width => ... }}
    volume =>{ y_axis =>{ light_width => ... }}

=cut

=head1 PRINCIPAL METHODS

=cut

sub add_price_line {
    my ($o, $data, $key, $style) = @_;
    unless (defined($style) and ref($style) eq 'PostScript::Graph::Style') {
	$style = {} unless defined $style;
	my $none = (defined($style->{line}) or defined($style->{point}));
	$style->{line} = {} unless $none;
	$style->{point} = {} unless $none;
	$style->{label} = $key unless defined $style->{label};
	$style->{sequence} = $o->price_sequence();
	$style = new PostScript::Graph::Style( $style ); 
    }
    push @{$o->{plines}}, [ $data, $style, $key, $o->{scount}++ ];
}
    
=head2 add_price_line( data, key [, style] )

=over 4

=item C<data>

An array ref indicating a list of points.  Each point has a date and a price value.  It is the callers
responsibility to check that the data will fit on the price graph.

=item C<key>

A string to appear next to the style in the Key box.

=item C<style>

This can either be a PostScript::Graph::Style object or a hash ref holding options for one.  The line is drawn
with the resulting style.  The styles for all lines are expected to belong to the same
PostScript::Graph::Sequence, even if the 'auto' feature is not being used.  This allows only the differences
between styles to be written to the PostScript file.

=back

Draw a line of one or more segments in given style.  The line is superimposed on the price chart, with the style
and text added to a Key area on the right.

Example

    my $pgs = new PostScript::Graph::Stock(
	    csv => 'prices.csv'
	);
   
    my $data = [
	    [ '2002-10-18', 462 ],
	    [ '2002-10-21', 396 ],
	    [ '2002-10-22', 129 ]
	];
    
    my $style = { 
	    auto    => 'none',
	    color   => 1,
	    line    => {
		width	=> 2,
		color	=> [0.7, 0, 0],
		dashes	=> [5, 5],
	    },
	    point   => {
		size	=> 4,
		shape	=> 'dot',
		color	=> [1, 0.3, 0],
	    },
	};
	
    $pgs->add_price_line( $data, $style, 'Example' );
    $pgs->output('pricegraph');

=cut

sub add_volume_line {
    my ($o, $data, $key, $style) = @_;
    unless (defined($style) and ref($style) eq 'PostScript::Graph::Style') {
	my $none = (defined($style->{line}) or defined($style->{point}));
	$style->{line} = {} unless $none;
	$style->{point} = {} unless $none;
	$style->{label} = $key unless defined $style->{label};
	$style->{sequence} = $o->volume_sequence();
	$style = new PostScript::Graph::Style( $style ); 
    }
    push @{$o->{vlines}}, [ $data, $style, $key, $o->{scount}++ ];
}
    
=head2 add_volume_line( data, key [, style] )

=over 4

=item C<data>

An array ref indicating a list of points.  Each point has a date and a volume.  It is the caller's
responsibility to check that the data will fit on the price graph.

=item C<key>

A string to appear next to the style in the Key box.

=item C<style>

This can either be a PostScript::Graph::Style object or a hash ref holding options for one.  The line is drawn
with the resulting style.  The styles for all lines are expected to belong to the same
PostScript::Graph::Sequence, even if the 'auto' feature is not being used.  This allows only the differences
between styles to be written to the PostScript file.

=back

Draw a line of one or more segments in given style.  The line is superimposed on the volume chart, with the style
and text added to a Key area on the right.

=cut

sub add_analysis_line {
    my ($o, $data, $key, $style) = @_;
    unless (defined($style) and ref($style) eq 'PostScript::Graph::Style') {
	my $none = (defined($style->{line}) or defined($style->{point}));
	$style->{line} = {} unless $none;
	$style->{point} = {} unless $none;
	$style->{label} = $key unless defined $style->{label};
	$style->{sequence} = $o->analysis_sequence();
	$style = new PostScript::Graph::Style( $style );
    }
    push @{$o->{alines}}, [ $data, $style, $key, $o->{scount}++ ];
}
    
=head2 add_analysis_line( data, key [, style] )

=over 4

=item C<data>

An array ref indicating a list of points.  Each point has a date and a volume.  It is the caller's
responsibility to check that the data will fit on the price graph.

=item C<key>

A string to appear next to the style in the Key box.

=item C<style>

This can either be a PostScript::Graph::Style object or a hash ref holding options for one.  The line is drawn
with the resulting style.  The styles for all lines are expected to belong to the same
PostScript::Graph::Sequence, even if the 'auto' feature is not being used.  This allows only the differences
between styles to be written to the PostScript file.

=back

Draw a line of one or more segments in given style.  The line is superimposed on the volume chart, with the style
and text added to a Key area on the right. For this to appear, B<new> options C<analysis_percent>, C<analysis_low>
and C<analysis_high> should have been set somehow.

=cut

sub build_graph {
    my $o = shift;
    my $s = $o->{sample};
    die "No price data\nStopped" unless (defined($s->{labels}) and @{$s->{labels}});
    
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
    PostScript::Graph::Key->ps_functions( $o->{pf} );
    PostScript::Graph::XY->ps_functions( $o->{pf} );
    PostScript::Graph::Stock->ps_functions( $o->{pf} );
    PostScript::Graph::Style->ps_functions( $o->{pf} );

    ## option hashes
    my $op   = $o->{op};
    my $opl  = $op->{layout};
    my $opx  = $op->{x_axis};
    my $opy  = $op->{y_axis};
    my $ops  = $op->{style};
    my $opk  = $op->{key};	
    my $opsp = $ops->{point};
    
    my $oa   = $o->{oa};
    my $oal  = $oa->{layout};
    my $oax  = $oa->{x_axis};
    my $oay  = $oa->{y_axis};
    my $oak  = $oa->{key};	
    
    my $ov   = $o->{ov};
    my $ovl  = $ov->{layout};
    my $ovx  = $ov->{x_axis};
    my $ovy  = $ov->{y_axis};
    my $ovs  = $ov->{style};
    my $ovk  = $ov->{key};	
    my $ovsb = $ovs->{bar};

    ## calculate height available
    my $fontsize;
    if ($o->{pprice}) {
	$fontsize = $opx->{font_size} || 10;
    } else {
	my $ovx = $o->{ov}{x_axis} || {};
	$fontsize = $ovx->{font_size} || 10;
    }
    my @pbox = $o->{pf}->get_page_bounding_box();
    my $label_height = $s->{lblmax} * 0.7 * $fontsize;
    my $height = $pbox[3] - $pbox[1] - $label_height;
    my $price_height = $height * $o->{pprice};
    my $anal_height = $height * $o->{panal};
    my $volume_height = $height * $o->{pvolume};
    my (%pstyles, %astyles, %vstyles);

    ## open dictionaries
    $o->{pf}->add_to_page( <<END_INIT );
	gpaperdict begin
	gstyledict begin
	xychartdict begin
	gstockdict begin
END_INIT
   
    ## create price key 
    my $key_width = 0;
    if ($o->{pprice} and $o->{key} and @{$o->{plines}}) {
	my $maxlen  = 0;
	my $maxsize = 0;
	my $lwidth  = 3;
	foreach my $line (@{$o->{plines}}) {
	    my ($data, $style, $key, $count) = @$line;
	    $pstyles{$style} = $line unless defined $pstyles{$style};
	    my $lw       = $style->use_line() ? $style->line_outer_width() : 0;
	    $lwidth      = $lw/2 if ($lw/2 > $lwidth);
	    my $size     = $style->use_point() ? $style->point_size() + $lwidth : $lwidth;
	    $maxsize     = $size if ($size > $maxsize);
	    my $len	 = length($key);
	    $maxlen	 = $len if ($len > $maxlen);
	    # ensure scale fits around line
	    foreach my $point (@$data) {
		my ($date, $y) = @$point;
		if (defined $y) {
		    $o->{pmin} = $y if $y < $o->{pmin};
		    $o->{pmax} = $y if $y > $o->{pmax};
		}
	    }
	}
	my $nlines = keys(%pstyles);
	
	if (defined $opk->{max_height}) {
	    $opk->{max_height} = $price_height if ($opk->{max_height} > $price_height);
	} else {
	    $opk->{max_height} = $price_height; 
	}
	$opk->{num_items}   = $nlines;
	$opk->{title}	    = 'Price key' unless (defined $opk->{title});
	my $tsize           = defined($opk->{text_size}) ? $opk->{text_size} : 10;
	$opk->{text_width}  = $maxlen * $tsize * $opk->{glyph_ratio};
	$opk->{icon_width}  = $maxsize * 3;
	$opk->{icon_height} = $maxsize * 1.5;
	$opk->{spacing}     = $lwidth;
	$opk->{file}	    = $o->{pf};
	$o->{ppk}           = new PostScript::Graph::Key( $opk );
	$key_width          = $o->{ppk}->width();
    }
    
    ## create analysis key 
    if ($o->{panal} and $o->{key} and @{$o->{alines}}) {
	my $maxlen  = 0;
	my $maxsize = 0;
	my $lwidth  = 3;
	$o->{amax} = -10 ** 20 unless defined $o->{amax};
	$o->{amin} = 10 ** 20  unless defined $o->{amin};
	foreach my $line (@{$o->{alines}}) {
	    my ($data, $style, $key) = @$line;
	    $astyles{$style} = $line;
	    my $lw       = $style->use_line() ? $style->line_outer_width() : 0;
	    $lwidth      = $lw/2 if ($lw/2 > $lwidth);
	    my $size     = $style->use_point() ? $style->point_size() + $lwidth : $lwidth;
	    $maxsize     = $size if ($size > $maxsize);
	    my $len	 = length($key);
	    $maxlen	 = $len if ($len > $maxlen);
	    # ensure scale fits around line
	    foreach my $point (@$data) {
		my ($date, $y) = @$point;
		if (defined $y) {
		    $o->{amin} = $y if $y < $o->{amin};
		    $o->{amax} = $y if $y > $o->{amax};
		}
	    }
	}
	my $nlines = keys(%astyles);
	
	if (defined $oak->{max_height}) {
	    $oak->{max_height} = $anal_height if ($oak->{max_height} > $anal_height);
	} else {
	    $oak->{max_height} = $anal_height; 
	}
	$oak->{num_items}   = $nlines;
	$oak->{title}	    = 'Analysis key' unless (defined $oak->{title});
	my $tsize           = defined($oak->{text_size}) ? $oak->{text_size} : 10;
	$oak->{text_width}  = $maxlen * $tsize * $oak->{glyph_ratio};
	$oak->{icon_width}  = $maxsize * 3;
	$oak->{icon_height} = $maxsize * 1.5;
	$oak->{spacing}     = $lwidth;
	$oak->{file}	    = $o->{pf};
	$o->{pak}           = new PostScript::Graph::Key( $oak );
	my $akw             = $o->{pak}->width();
	$key_width          = $akw if ($akw > $key_width);
    }

    ## create volume key 
    if ($o->{pvolume} and $o->{key} and @{$o->{vlines}}) {
	my $maxlen  = 0;
	my $maxsize = 0;
	my $lwidth  = 3;
	foreach my $line (@{$o->{vlines}}) {
	    my ($data, $style, $key) = @$line;
	    $vstyles{$style} = $line;
	    my $lw       = $style->use_line() ? $style->line_outer_width() : 0;
	    $lwidth      = $lw/2 if ($lw/2 > $lwidth);
	    my $size     = $style->use_point() ? $style->point_size() + $lwidth : $lwidth;
	    $maxsize     = $size if ($size > $maxsize);
	    my $len	 = length($key);
	    $maxlen	 = $len if ($len > $maxlen);
	    # ensure scale fits around line
	    foreach my $point (@$data) {
		my ($date, $y) = @$point;
		if (defined $y) {
		    $o->{vmin} = $y if $y < $o->{vmin};
		    $o->{vmax} = $y if $y > $o->{vmax};
		}
	    }
	}
	my $nlines = keys(%vstyles);
	
	if (defined $ovk->{max_height}) {
	    $ovk->{max_height} = $volume_height if ($ovk->{max_height} > $volume_height);
	} else {
	    $ovk->{max_height} = $volume_height; 
	}
	$ovk->{num_items}   = $nlines;
	$ovk->{title}	    = 'Volume key' unless (defined $ovk->{title});
	my $tsize           = defined($ovk->{text_size}) ? $ovk->{text_size} : 10;
	$ovk->{text_width}  = $maxlen * $tsize * $ovk->{glyph_ratio};
	$ovk->{icon_width}  = $maxsize * 3;
	$ovk->{icon_height} = $maxsize * 1.5;
	$ovk->{spacing}     = $lwidth;
	$ovk->{file}	    = $o->{pf};
	$o->{pvk}           = new PostScript::Graph::Key( $ovk );
	my $vkw             = $o->{pvk}->width();
	$key_width          = $vkw if ($vkw > $key_width);
    }

    ## create price grid
    if ($o->{pprice}) {
	$op->{file}            = $o->{pf};
	$opl->{key_width}      = $key_width;
	$opl->{bottom_edge}    = $pbox[1] + $volume_height + $anal_height;
	$opl->{no_drawing}     = 1;
	$opx->{draw_fn}        = "xdrawstock";
	$opx->{labels}         = $s->{labels};
	$opx->{show_lines}     = 1 unless (defined $opx->{show_lines});
	$opx->{offset}         = 1;
	$opx->{sub_divisions}  = 2;
	$opx->{center}         = 0;
	$opx->{mark_max}       = 4 unless (defined $opx->{mark_max});
	$opx->{height}         = $label_height;
	$opy->{low}            = $o->{pmin};
	$opy->{high}           = $o->{pmax};
	$opy->{si_shift}       = 2 unless (defined $opy->{si_shift});
	$o->{pp}               = new PostScript::Graph::Paper( $op );
    }
    
    ## create analysis grid
    if ($o->{panal}) {
	$oa->{file}                = $o->{pf};
	if ($o->{pprice}) {
	    $oal->{heading_height} = 0 unless (defined $oax->{heading_height});
	    $oax->{mark_max}       = 0 unless (defined $oax->{mark_max});
	    $oax->{height}         = 5 unless (defined $oax->{height});
	}
	$oal->{top_edge}       = $pbox[1] + $volume_height + $anal_height;
	$oal->{bottom_edge}    = $pbox[1] + $volume_height;
	$oal->{key_width}      = $key_width;
	$oal->{no_drawing}     = 1;
	$oax->{draw_fn}        = "xdrawstock";
	$oax->{labels}         = $s->{labels};
	$oax->{show_lines}     = $ov->{show_lines} if (defined $oa->{show_lines});
	$oax->{show_lines}     = 1 unless (defined $oax->{show_lines});
	$oax->{offset}         = 1;
	$oax->{sub_divisions}  = 2;
	$oax->{center}         = 0;
	$oay->{low}            = $o->{amin};
	$oay->{high}           = $o->{amax};
	$oay->{label_gap}      = 14;
	$o->{pa}               = new PostScript::Graph::Paper( $oa );
    }
     ## create volume grid
    if ($o->{pvolume}) {
	$ov->{file}                = $o->{pf};
	if ($o->{pprice}) {
	    $ovl->{heading_height} = 0 unless (defined $ovx->{heading_height});
	    $ovx->{mark_max}       = 0 unless (defined $ovx->{mark_max});
	    $ovx->{height}         = 5 unless (defined $ovx->{height});
	}
	$ovl->{top_edge}       = $pbox[1] + $volume_height;
	$ovl->{key_width}      = $key_width;
	$ovl->{no_drawing}     = 1;
	$ovx->{draw_fn}        = "xdrawstock";
	$ovx->{labels}         = $s->{labels};
	$ovx->{show_lines}     = $ov->{show_lines} if (defined $ov->{show_lines});
	$ovx->{show_lines}     = 1 unless (defined $ovx->{show_lines});
	$ovx->{offset}         = 1;
	$ovx->{sub_divisions}  = 2;
	$ovx->{center}         = 0;
	$ovy->{low}            = $o->{vmin};
	$ovy->{high}           = $o->{vmax};
	$ovy->{label_gap}      = 14;
	$o->{pv}               = new PostScript::Graph::Paper( $ov );
    }
   
    ## prepare labels and draw grids
    my $pp = $o->{pp};
    my $pa = $o->{pa};
    my $pv = $o->{pv};
    my $space = $pp ? $pp->x_axis_font_size()/2 : $pv->x_axis_font_size()/2;
    my $step  = $pp ? $pp->x_axis_mark_gap()    : $pv->x_axis_mark_gap();
    my $taken = $space;
    my $plabels = $s->{labels};
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
    if ($o->{panal}) {
	$pa->x_axis_labels( $vlabels );
	$pa->draw_scales();
    }
    if ($o->{pvolume}) {
	if ($o->{pprice}) {
	    $pv->x_axis_labels( $vlabels );
	} else {
	    $pv->x_axis_labels( $plabels );
	}
	$pv->draw_scales();
    }

    ## add price marks
    if ($o->{pprice}) {
	my $pstyle = new PostScript::Graph::Style( $ops );
	$pstyle->background( $o->{pp}->layout_background() );
	$pstyle->write( $o->{pf} );
	my $dates  = $s->{dates};
	my $prices = $s->{price};
	my $order  = $s->{order};
	my $gp     = $o->{pp};
	for (my $d = 0; $d <= $#{$s->{dates}}; $d++) {
	    my $date   = $dates->[$d];
	    my $price  = $prices->{$date};
	    my $x      = $order->{$date};
	    my $psx    = $gp->px( $x );
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
	$vstyle->background( $o->{pv}->layout_background() );
	$vstyle->write( $o->{pf} );
	my $vols  = $s->{volume};
	my $dates = $s->{dates};
	my $order = $s->{order};
	for (my $d = 0; $d <= $#{$s->{dates}}; $d++) {
	    my $date = $dates->[$d];
	    my $x = $order->{$date};
	    my $y = $vols->{$date};
	    if (defined $y) {
		my @bb     = $o->{pv}->vertical_bar_area($x * 2, $y);
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

    ## write out lines
    $o->build_lines( $o->{plines}, \%pstyles, $o->{pp}, $o->{ppk} );
    $o->build_lines( $o->{alines}, \%astyles, $o->{pa}, $o->{pak} );
    $o->build_lines( $o->{vlines}, \%vstyles, $o->{pv}, $o->{pvk} );

    ## close dictionaries
    $o->{pf}->add_to_page( "end end end end\n" );
}

=head2 build_graph

This will not need to be called in most circumstances as it is called automatically by B<output>.

However, if more than one graph is being written to the same PostScript::File document, this will need to be
called directly.  It constructs the PostScript code for the graph without actually saving the file.

Example

    use PostScript::Graph::Stock;
    use PostScript::File;
    my $psfile = new PostScript::File();
    
	my $gs1 = new PostScript::Graph::Stock(
			file => $psfile,
		    );
	$gs1->data_from_file( 'stock1.csv' );
	$gs1->build_graph();
   
    $psfile->newpage();
    
	my $gs2 = new PostScript::Graph::Stock(
			file => $psfile,
		    );
	$gs2->data_from_file( 'stock2.csv' );
	$gs2->build_graph();
    
    $psfile->output( 'graph' );

=cut

sub output {
    my $o = shift;
    $o->build_graph() unless (defined $o->{pf});
    $o->{pf}->output(@_);
}

=head2 output( file [, dir] )

The charts are constructed and written out to a PostScript file.  A suitable suffix (.ps, .epsi or .epsf) will be
appended to the file name.

=cut

=head1 ACCESS METHODS

=cut

sub file {
    return shift()->{pf};
}

=head3 file

Return the underlying PostScript::File object.

=cut

sub price_graph_paper {
    return shift()->{pp};
}

=head3 price_graph_paper

Return the PostScript::Graph::Paper object upon which the prices are drawn.

=cut

sub volume_graph_paper {
    return shift()->{pv};
}

=head3 volume_graph_paper

Return the PostScript::Graph::Paper object upon which the volume data are drawn.

=cut

sub price_sequence {
    my $o = shift;
    $o->{pseq} = ($o->{op}{sequence} || new PostScript::Graph::Sequence) unless defined $o->{pseq};
    return $o->{pseq};
}

=head2 price_sequence

Return the PostScript::Graph::Sequence used to keep track of the style defaults used for price lines.  This call
creates such an object if it doesn't already exist.

=cut

sub volume_sequence {
    my $o = shift;
    $o->{vseq} = ($o->{ov}{sequence} || new PostScript::Graph::Sequence) unless defined $o->{vseq};
    return $o->{vseq};
}

=head2 volume_sequence

Return the PostScript::Graph::Sequence used to keep track of the style defaults used for volume lines.  This call
creates such an object if it doesn't already exist.

=cut

sub analysis_sequence {
    my $o = shift;
    $o->{aseq} = ($o->{oa}{sequence} || new PostScript::Graph::Sequence) unless defined $o->{aseq};
    return $o->{aseq};
}

=head2 analysis_sequence

Return the PostScript::Graph::Sequence used to keep track of the style defaults used for price lines.  This call
creates such an object if it doesn't already exist.

=cut

### Support methods

sub from_csv {
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

    $o->from_array( \@data );
}

sub from_array {
    my ($o, $data) = @_;
    die "Array required\nStopped" unless (defined $data);
  
    my $sample = new Finance::Shares::Sample(
		source	=> $data,
		epic	=> $o->{epic},
		graph	=> {
		    dates   => $o->{od},
		}
	    );
    $sample->prepare_dates( $data );
    $o->from_sample( $sample );
}

sub from_sample {
    my ($o, $s) = @_;
    $o->{sample} = $s if (defined $s);
    die "No Finance::Shares::Sample object\nStopped" unless ($o->{sample});

    ## identify first and last dates
    my ($dfirst, $dlast, @first, @last);
    foreach my $date ($s->{dates}) {
	$dfirst = $date if (not defined($dfirst) or $date < $dfirst);
	$dlast  = $date if (not defined($dlast)  or $date > $dlast);
    }

    ## identify price range
    my ($pmin, $pmax);
    foreach my $pdata (values %{$s->{price}}) {
	my ($open, $high, $low, $close) = @$pdata;
	$pmin = $open  if (not defined($pmin) or $open < $pmin);
	$pmax = $high  if (not defined($pmax) or $high > $pmax);
	$pmin = $low   if (not defined($pmin) or $low < $pmin);
	$pmin = $close if (not defined($pmin) or $close < $pmin);
    }

    ## identify volume range
    my ($vmin, $vmax);
    foreach my $volume (values %{$s->{volume}}) {
	$vmin = $volume if (not defined($vmin) or $volume < $vmin);
	$vmax = $volume if (not defined($vmax) or $volume > $vmax);
    }
    
    ## price:volume proportion
    CASE: {
	if (not defined($pmin) and not defined($vmin)) {
	    die "No price or volume data\nStopped";
	}
	if (not defined($pmin) and defined($vmin)) {
	    $o->{pprice} = 0; $o->{pvolume} = 1;
	    last CASE;
	}
	if (($o->{dtype} eq 'months') or (defined($pmin) and not defined($vmin))) {
	    $o->{pprice} = 1; $o->{pvolume} = 0;
	    last CASE;
	}
	if (defined($pmin) and defined($vmin)) {
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
}

sub build_lines {
    my ($o, $lines, $styles, $paper, $key) = @_;
    return unless (@$lines);
    my $s = $o->{sample};
    
    $key->build_key($paper) if (defined $key);
    my ($cmd, $keylines, $keyouter, $keyinner);
    foreach my $line (@$lines) {
	my ($data, $style, $key) = @$line;
	$style->background( $paper->layout_background() );
	$style->write( $o->{pf} );
	
	## construct price point data
	my $points = "";
	my $npoints = -1;
	foreach my $row (@$data) {
	    my ($date, $y) = @$row;
	    if (defined $y) {
		my $x = $s->{order}{$date} + 0.5;
		my $px = $paper->px($x);
		my $py = $paper->py($y);
		$points = "$px $py " . $points;
		$npoints += 2;
	    }
	}

	## prepare code for price points and lines
	CASE: {
	    if (    $style->use_point() and     $style->use_line()) {
		$cmd = "xyboth";
		$keyouter = "point_outer kpx kpy draw1point";
		$keylines = "[ kix0 kiy0 kix1 kiy1 ] 3 2 copy line_outer drawxyline line_inner drawxyline";
		$keyinner = "point_inner kpx kpy draw1point";
	    }
	    if (    $style->use_point() and not $style->use_line()) {
		$cmd = "xypoints";
		$keyouter = "point_outer kpx kpy draw1point";
		$keylines = "";
		$keyinner = "point_inner kpx kpy draw1point";
	    }
	    if (not $style->use_point() and     $style->use_line()) {
		$cmd = "xyline";
		$keyouter = "";
		$keylines = "[ kix0 kiy0 kix1 kiy1 ] 3 2 copy line_outer drawxyline line_inner drawxyline";
		$keyinner = "";
	    }
	    if (not $style->use_point() and not $style->use_line()) {
		$cmd = "";
		$keyouter = "";
		$keylines = "";
		$keyinner = "";
	    }
	}

	$o->{pf}->add_to_page( "[ $points ] $npoints $cmd\n" ) if ($cmd);
    }

    ## make key entries
    my @styles = sort { $a->[3] <=> $b->[3]; } values(%$styles);
    foreach my $s (@styles) {
	my ($data, $style, $text) = @$s;
	$style->background( $paper->layout_background() );
	$style->write( $o->{pf} );
	
	## prepare code for price points and lines
	CASE: {
	    if (    $style->use_point() and     $style->use_line()) {
		$cmd = "xyboth";
		$keyouter = "point_outer kpx kpy draw1point";
		$keylines = "[ kix0 kiy0 kix1 kiy1 ] 3 2 copy line_outer drawxyline line_inner drawxyline";
		$keyinner = "point_inner kpx kpy draw1point";
	    }
	    if (    $style->use_point() and not $style->use_line()) {
		$cmd = "xypoints";
		$keyouter = "point_outer kpx kpy draw1point";
		$keylines = "";
		$keyinner = "point_inner kpx kpy draw1point";
	    }
	    if (not $style->use_point() and     $style->use_line()) {
		$cmd = "xyline";
		$keyouter = "";
		$keylines = "[ kix0 kiy0 kix1 kiy1 ] 3 2 copy line_outer drawxyline line_inner drawxyline";
		$keyinner = "";
	    }
	    if (not $style->use_point() and not $style->use_line()) {
		$cmd = "";
		$keyouter = "";
		$keylines = "";
		$keyinner = "";
	    }
	}

	$key->add_key_item( $text, <<END_PRICE_KEY ) if (defined $key);
	    2 dict begin
		/kpx kix0 kix1 add 2 div def
		/kpy kiy0 kiy1 add 2 div def
		$keyouter
		$keylines
		$keyinner
	    end
END_PRICE_KEY
    }
}
## Draw lines on specified graph paper.
# Called from build_graph.

=head1 CLASS METHODS

The PostScript code is a class method so that it may be available to other classes that don't need a Stock object.

The useful functions in the 'gstockdict' dictionary draw a stock chart mark and a close mark in
either one or two colours.

   make_stock
   make_stock2
   make_close
   make_close2

The all consume 5 numbers from the stack (even if they aren't all used):

    x yopen ylow yhigh yclose
   
=cut

sub ps_functions {
    my ($class, $ps) = @_;

    my $name = "StockChart";
    $ps->add_function( $name, <<END_FUNCTIONS ) unless ($ps->has_function($name));
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

=head1 BUGS

This module is quite complex and still in the early stages of testing.  So please report any bugs you find to the
author.

=head1 AUTHOR

Chris Willmot, chris@willmot.co.uk or cpwillmot@cpan.org

=head1 SEE ALSO

L<PostScript::File>, 
L<PostScript::Graph::Style>,  
L<PostScript::Graph::Key>, 
L<PostScript::Graph::Paper>,
L<PostScript::Graph::XY>, 
L<PostScript::Graph::Bar>,
L<Finance::Shares::Sample> and
L<Finance::Shares::MySQL>.

=cut

1;
