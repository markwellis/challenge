package Challenge::Graph::DB;
use Moo;

use DBI;
use Try::Tiny;
use Challenge::Graph;

has dsn => ( is => 'ro', required => 1 );
has username => ( is => 'ro', required => 1 );
has password => ( is => 'ro', required => 1 );
has attrs => ( is => 'ro', required => 1 );

our $_NO_COMMIT; #localise this in replace to delete/create to one transaction

has dbh => (
    is          => 'ro',
    lazy        =>1,
    builder     => '_build_dbh',
    predicate   => '_has_dbh',
);
sub _build_dbh {
    my $self = shift;

    my $attrs = {
        %{$self->attrs},
        RaiseError => 1, #better error handling (dies)
        AutoCommit => 0, #manual transactions
        PrintError => 0, #don't print errors, we'll handle that
    };

    my $dbh = DBI->connect(
        $self->dsn,
        $self->username,
        $self->password,
        $attrs,
    );

    return $dbh;
}

sub DEMOLISH {
    my $self = shift;

    #close db connection
    if ( $self->_has_dbh ) {
        $self->dbh->disconnect;
    }
}

sub load {
    my ( $self, $graph_id ) = @_;

    #DBIx::Class would have made this so much easier, but I think it might be cheating...
    my $sth = $self->dbh->prepare(
        'SELECT
            graphs.id, graphs.name, nodes.id, nodes.name, edges.id, edges.to, edges.from, edges.cost
        FROM graphs
            LEFT JOIN nodes ON ( graphs.id = nodes.graph_id )
            LEFT JOIN edges ON ( graphs.id = edges.graph_id )
        WHERE graphs.id = ?'
    ) ;
    $sth->execute( $graph_id );

    my $graph_raw = {
        nodes   => {},
        edges   => {},
    };

    #all nodes and edges have a unique id, so this will work
    foreach my $row ( @{$sth->fetchall_arrayref} ) {
        $graph_raw->{id} //= $row->[0];
        $graph_raw->{name} //= $row->[1];
        $graph_raw->{nodes}->{ $row->[2] } //= {
            id      => $row->[2],
            name    => $row->[3],
        };
        $graph_raw->{edges}->{ $row->[4] } //= {
            id      => $row->[4],
            to      => $row->[5],
            from    => $row->[6],
            cost    => $row->[7],
        };
    }

    my @nodes = values %{$graph_raw->{nodes}};
    my @edges = values %{$graph_raw->{edges}};

    return Challenge::Graph->new(
        id    => $graph_raw->{id},
        name  => $graph_raw->{name},
        nodes => \@nodes,
        edges => \@edges,
    );
}

sub exists {
    my ( $self, $graph ) = @_;

    my $sth = $self->dbh->prepare( 'SELECT 1 FROM "graphs" WHERE "id" = ?' ) ;
    $sth->execute( $graph->id );

    if ( $sth->rows ) {
        return 1;
    }

    return;
}

sub replace {
    my ( $self, $graph ) = @_;

    try {
        #localise this so that we don't commit after deleting,
        # or rollback elsewhere of there's an error
        local $_NO_COMMIT = 1;
        $self->delete( $graph ) if $self->exists( $graph );
        $self->save( $graph );

        $self->dbh->commit;
    }
    catch {
        $self->dbh->rollback or die $self->dbh->errstr;
        die "delete failed: $_";
    };
}

sub delete {
    my ( $self, $graph ) = @_;

    try {
        my $delete_edges = $self->dbh->prepare( 'DELETE FROM "edges" WHERE "graph_id" = ?' ) ;
        my $delete_nodes = $self->dbh->prepare( 'DELETE FROM "nodes" WHERE "graph_id" = ?' ) ;
        my $delete_graph = $self->dbh->prepare( 'DELETE FROM "graphs" WHERE "id" = ?' ) ;

        $delete_edges->execute( $graph->id );
        $delete_nodes->execute( $graph->id );
        $delete_graph->execute( $graph->id );

        $self->dbh->commit if !$_NO_COMMIT;
    }
    catch {
        #i dislike double negatives, but feel it makes it clear that
        # it not commiting is the exception, not the norm
        if ( !$_NO_COMMIT ) {
            $self->dbh->rollback or die $self->dbh->errstr;
            die "delete failed: $_";
        }
        else {
            die $_;
        }
    };
}

sub save {
    my ( $self, $graph ) = @_;

    try {
        #prepare some statements
        my $insert_graph = $self->dbh->prepare(
            'INSERT INTO "graphs" ( "id", "name" ) VALUES ( ?, ? )'
        );
        my $insert_node = $self->dbh->prepare(
            'INSERT INTO "nodes" ( "graph_id", "id", "name" ) VALUES ( ?, ?, ? )'
        );
        my $insert_edge = $self->dbh->prepare(
            'INSERT INTO "edges" ( "graph_id", "id", "to", "from", "cost" ) VALUES ( ?, ?, ?, ?, ? )'
        );

        #insert
        $insert_graph->execute( $graph->id, $graph->name );
        foreach my $node ( @{$graph->nodes} ) {
            $insert_node->execute( $graph->id, $node->{id}, $node->{name} );
        }
        foreach my $edge ( @{$graph->edges} ) {
            $insert_edge->execute( $graph->id, $edge->{id}, $edge->{to}, $edge->{from}, $edge->{cost} );
        }

        $self->dbh->commit if !$_NO_COMMIT;
    }
    catch {
        if ( !$_NO_COMMIT ) {
            $self->dbh->rollback or die $self->dbh->errstr;
            die "save failed: $_";
        }
        else {
            die $_;
        }
    };
}

__PACKAGE__->meta->make_immutable;
