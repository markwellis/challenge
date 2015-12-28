use strict;
use warnings;
use Test::More tests => 11;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::Graph::XML;
use Path::Tiny;

{
    my $xml = path("$Bin/test_data/02/simple.xml")->slurp_utf8;

    my $graph_xml = Challenge::Graph::XML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph ok";

    #this also tests that cycles are ignored
    is_deeply
        $graph_xml->graph->paths('a', 'c'),
        [["a", "b", "c"], ["a", "c"]],
        "correct paths a => c";

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

{
    my $xml = path("$Bin/test_data/02/branched.xml")->slurp_utf8;

    my $graph_xml = Challenge::Graph::XML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph ok";
    #this also tests that cycles are ignored
    is_deeply
        $graph_xml->graph->paths('a', 'c'),
        [["a", "b", "c"], ["a", "b", "e", "c"], ["a", "c"]],
        "correct paths a => c";

    is_deeply
        $graph_xml->graph->paths('a', 'd'),
        [["a", "b", "c", "d"], ["a", "b", "d"], ["a", "b", "e", "c", "d"], ["a", "c", "d"]],
        "correct paths a => d";

    is_deeply
        $graph_xml->graph->paths('a', 'e'),
        [["a", "b", "e"]],
        "correct path a => e";

    is_deeply
        $graph_xml->graph->cheapest('a', 'd'),
        ["a", "c", "d"],
        "correct cheapest a => d";

    is_deeply
        $graph_xml->graph->cheapest('a', 'e'),
        ["a", "b", "e"],
        "correct cheapest a => e";
}
