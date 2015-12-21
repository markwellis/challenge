use strict;
use warnings;
use Test::More tests => 2;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::Graph::XML;
use Path::Tiny;

{
    my $xml = path("$Bin/../xml/g0.xml")->slurp_utf8;

    my $graph_xml = Challenge::Graph::XML->new(
        url => "https://raw.githubusercontent.com/markwellis/challenge/master/xml/g0.xml",
    );

    is $graph_xml->xml, $xml, "fetched xml loaded";

    ok $graph_xml->graph, "graph ok";
}
