use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Getopt::Long;
use Config::ZOMG;

use Challenge::Graph::XML;
use Challenge::Graph::DB;

#no one likes hard-coded config options
my $config = Config::ZOMG->open(
    name => 'challenge',
    path => "$Bin/..",
) || die "couldn't load config file\n";

my %opt;
GetOptions (
    \%opt,
    "xml_url=s",
    "replace",
    "verbose|v",
) || die "need xml_url\n";

#the prototype means it accepts 1 scalar and doesn't need parenthesis
sub info ($) {
    print "$_[0]\n" if $opt{verbose};
}

info "loading url";
my $graph_xml = Challenge::Graph::XML->new( url => $opt{xml_url} );

info "parsing xml";
my $graph = $graph_xml->graph;

info "connecting to db";
my $graph_db = Challenge::Graph::DB->new( $config->{db} );

if ( $opt{replace} ) {
    info "replacing " . $graph->id;
    $graph_db->replace( $graph );
}
else {
    info "saving " . $graph->id;
    $graph_db->save( $graph );
}
