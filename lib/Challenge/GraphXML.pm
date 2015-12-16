package Challenge::GraphXML;
use Moo;
use Types::Standard -types;

use XML::Twig;
use Challenge::Graph;
use Scalar::Util qw/looks_like_number/;

has xml => (
    is          => 'ro',
    required    => 1,
);

has graph => (
    is          => 'ro',
    builder     => '_build_graph',
    init_arg    => undef,
    lazy        => 1,
);
sub _build_graph {
    my $self = shift;

    my %node_ids;
    my $graph = {};

    #this sub is ugly because it has a lot of subrefs for callbacks

    #die with a more helpful error
    my $die = sub {
        my ( $error, $twig ) = @_;

        die "error: $error at xml line " . $twig->current_line . "\n";
    };

    #for parsing/validating nodes
    my $parse_node = sub {
        my ( $twig, $node ) = @_;

        #all nodes must have a name/id
        my $node_name = $node->first_child_text( 'name' );
        my $node_id = $node->first_child_text( 'id' );

        if ( !defined( $node_name ) || ( $node_name eq '' ) ) {
            $die->( "no node name", $twig );
        }
        if ( !defined( $node_id ) || ( $node_id eq '' ) ) {
            $die->( "no node id", $twig );
        }

        #all nodes must have different ids
        $die->( "node id $node_id seen more than once!", $twig )
            if $node_ids{ $node_id }++;

        my $node_data = {
            id      => $node_id,
            name    => $node_name,
        };

        push @{$graph->{nodes}}, $node_data;
    };

    #for parsing/validating edges
    my $parse_edge = sub {
        my ( $twig, $edge ) = @_;

        #if there's no nodes, don't say the edge is invalid, as it's not helpful
        die "need at least one node!\n" if !exists $graph->{nodes};

        my $edge_id = $edge->first_child_text( 'id' );
        my $edge_from = $edge->first_child_text( 'from' );
        my $edge_to = $edge->first_child_text( 'to' );

        #each node id/to/from must be provided
        if ( !defined( $edge_id ) || ( $edge_id eq '' ) ) {
            $die->( "no edge id", $twig );
        }
        if ( !defined( $edge_from ) || ( $edge_from eq '' ) ) {
            $die->( "no edge from", $twig );
        }
        if ( !defined( $edge_to ) || ( $edge_to eq '' ) ) {
            $die->( "no edge to", $twig );
        }

        #every edge must have only one to/from and must point to a real node
        foreach my $type ( qw/to from/ ) {
            my $count = $edge->children_count( $type );
            $die->( "node has " . $count . " ${type} tags, it should have 1", $twig )
                if $count != 1;
        }

        $die->( "invalid edge from (no node with that id)", $twig )
            if !$node_ids{ $edge_from };

        $die->( "invalid edge to (no node with that id)", $twig )
            if !$node_ids{ $edge_to };


        #cost must be >= 0
        my $edge_cost = $edge->field( 'cost' );
        $die->( "cost should be a number", $twig )
            if ( $edge_cost && !looks_like_number( $edge_cost ) );
        $die->( "cost can't be negative", $twig )
            if ( $edge_cost && ( $edge_cost < 0 ) );

        my $edge_data = {
            id   => $edge_id,
            to   => $edge_to,
            from => $edge_from,
            cost => $edge_cost || 0,
        };

        push @{$graph->{edges}}, $edge_data;
    };

    #for the root name/id
    my $parse_root_element = sub {
        my ( $twig, $el ) = @_;

        $die->( $el->name . " already set", $twig )
            if exists $graph->{ $el->name };

        $graph->{ $el->name } = $el->text;
    };

    #according to the spec, we can assume nodes will always be before edges
    my $twig = XML::Twig->new(
        twig_handlers => {
            '/graph/nodes/node' => $parse_node,
            '/graph/edges/node' => $parse_edge,
            '/graph/name'    => $parse_root_element,
            '/graph/id'    => $parse_root_element,
        }
    );
    $twig->parse( $self->xml );

    #free the memory we used for parsing the xml
    $twig->purge;

    #build Challenge::Graph (encapsulates & does more validation, e.g. checks for at least one node)
    return Challenge::Graph->new( $graph );
}

__PACKAGE__->meta->make_immutable;
