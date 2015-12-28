use strict;
use warnings;
use Test::More tests => 5;
use Path::Tiny;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Config::ZOMG;
use Challenge::Graph::XML;
use Challenge::Graph::DB;

#no one likes hard-coded config options
my $config = Config::ZOMG->open(
    name => 'challenge',
    path => "$Bin/..",
) || die "couldn't load config file\n";

my $graph_db = Challenge::Graph::DB->new( $config->{db} );

my @graphs;
foreach ( qw/first second/ ) {
    my $xml = path("$Bin/test_graphs/06/$_.xml")->slurp_utf8;
    my $graph_xml = Challenge::Graph::XML->new( xml => $xml );
    push @graphs, $graph_xml->graph;
}

cleanup();

is @graphs, 2, "2 graphs";
{
    my $graph = $graphs[0];
#save
    $graph_db->save( $graph );

#load
    my $loaded_graph = $graph_db->load( 'test' );
    compare_graphs( $graph, $loaded_graph );
}

{
    my $graph = $graphs[1];
#replace
    $graph_db->replace( $graph );

#load
    my $loaded_graph = $graph_db->load( 'test' );
    compare_graphs( $graph, $loaded_graph );
}

cleanup();

sub compare_graphs {
    my ( $graph, $loaded_graph ) = @_;

    subtest "comapre graphs" => sub {
        plan tests => 6;

        is $graph->name, $loaded_graph->name, "same name " . $graph->name;
        is $graph->id, $loaded_graph->id, "same id";
        is scalar @{$graph->nodes}, scalar @{$loaded_graph->nodes}, "same number of nodes";
        is scalar @{$graph->edges}, scalar @{$loaded_graph->edges}, "same number of edges";
        is_deeply
            [sort { $a->{id} cmp $b->{id} } @{$graph->nodes}],
            [sort { $a->{id} cmp $b->{id} } @{$loaded_graph->nodes}],
            "nodes match";
        is_deeply
            [sort { $a->{id} cmp $b->{id} } @{$graph->edges}],
            [sort { $a->{id} cmp $b->{id} } @{$loaded_graph->edges}],
            "edges match";
    };
}

sub cleanup {
    $graph_db->delete( 'test' );
    ok !$graph_db->load( 'test' ), "no test graph";
}
