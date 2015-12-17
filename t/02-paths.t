use strict;
use warnings;
use Test::More tests => 9999;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::GraphXML;
use Path::Tiny;

{
    my $xml = path("$Bin/test_graphs/02/simple.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph ok";

    is_deeply
        $graph_xml->graph->paths('a', 'c'),
        [["a", "b", "c"], ["a", "c"]],
        "correct paths";

    is_deeply
        $graph_xml->graph->paths('a', 'd'),
        [],
        "no paths (d doesn't exist)";

    is_deeply
        $graph_xml->graph->cheapest('a', 'c'),
        ["a", "c"],
        "correct cheapest a => c";

    ok !$graph_xml->graph->cheapest('a', 'e'), "no cheapest from a => e";
}
