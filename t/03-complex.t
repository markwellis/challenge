use strict;
use warnings;
use Test::More tests => 9;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::Graph::XML;
use Path::Tiny;

{
    my $xml = path("$Bin/../xml/g0.xml")->slurp_utf8;

    my $graph_xml = Challenge::Graph::XML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph ok";

    is_deeply
        $graph_xml->graph->paths('a', 'c'),
        [["a", "c"]],
        "correct paths a => c";

    is_deeply
        $graph_xml->graph->paths('a', 'd'),
        [[qw/a c d/]],
        "correct paths a => d";

    is_deeply
        $graph_xml->graph->paths('a', 'e'),
        [[qw/a b e/], [qw/a c e/]],
        "correct paths a => f";

    is_deeply
        $graph_xml->graph->paths('a', 'f'),
        [[qw/a c d f/], [qw/a c f/]],
        "correct paths a => f";

    is_deeply
        $graph_xml->graph->paths('g', 'b'),
        [],
        "no paths from g => b";

    is_deeply
        $graph_xml->graph->cheapest('a', 'f'),
        ["a", "c", "d", "f"],
        "correct cheapest a => f";

    is_deeply
        $graph_xml->graph->cheapest('a', 'e'),
        [qw/a b e/],
        "correct cheapest a => e";

    ok !$graph_xml->graph->cheapest('g', 'i'), "no cheapest from a => e";
}
