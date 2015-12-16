use strict;
use warnings;
use Test::More tests => 9999;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::GraphXML;
use Path::Tiny;

{
    my $xml = path("$Bin/test_graphs/valid.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph is valid";
use Data::Dumper::Concise;
warn Dumper( $graph_xml->graph );
}

#{
#    my $xml = path("$Bin/test_graphs/graph_no_id.xml")->slurp_utf8;
#
#    my $graph = Challenge::GraphXML->new(
#        xml => $xml,
#    );
#
#    ok !$graph->valid, "graph is invalid";
#    is $graph->error, ""
#}
