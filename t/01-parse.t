use strict;
use warnings;
use Test::More tests => 9999;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::GraphXML;
use Path::Tiny;

{
    my $xml = path("$Bin/test_graphs/graph_no_id.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/missing required arguments: id/i, "dies no graph id";
}
{
    my $xml = path("$Bin/test_graphs/graph_no_name.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/missing required arguments: name/i, "dies no graph name";
}
{
    my $xml = path("$Bin/test_graphs/no_nodes_has_edges.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/need at least one node/i, "dies no nodes";
}
{
    my $xml = path("$Bin/test_graphs/no_nodes_no_edges.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/need at least one node/i, "dies no nodes";
}
{
    my $xml = path("$Bin/test_graphs/node_duplicate_id.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/node id a seen more than once/i, "dies duplicate node id";
}
{
    my $xml = path("$Bin/test_graphs/edge_many_from.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/node has 2 from tags/i, "dies edge too many from tags";
}
{
    my $xml = path("$Bin/test_graphs/edge_many_to.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/node has 2 to tags/i, "dies edge too many to tags";
}
{
    my $xml = path("$Bin/test_graphs/edge_from_invalid_node.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/invalid edge from/i, "dies edge from invalid node";
}
{
    my $xml = path("$Bin/test_graphs/edge_to_invalid_node.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/invalid edge to/i, "dies edge to invalid node";
}
{
    my $xml = path("$Bin/test_graphs/invalid_cost_not_number.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/cost should be a number/i, "dies cost not a number";
}
{
    my $xml = path("$Bin/test_graphs/invalid_cost_negative.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    eval {
        $graph_xml->graph;
    };
    like $@, qr/cost can't be negative/i, "dies cost negative";
}

{
    my $xml = path("$Bin/test_graphs/valid_no_cost.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph is valid without edge cost";

    #XXX make this work, needs edge object and stuff
    # it works, but there's no way to check atm
    ok 0, "cost defaults to 0 if not provided";
}
{
    my $xml = path("$Bin/test_graphs/valid_with_cost.xml")->slurp_utf8;

    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    ok $graph_xml->graph, "graph is valid with edge cost";
}

ok 0, "add tests that check the document is valid and not jibberish";
