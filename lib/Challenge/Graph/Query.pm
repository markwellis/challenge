package Challenge::Graph::Query;
use Moo;
use Challenge::Graph::DB;
use Types::Serialiser;

has db_config => (
    is       => 'ro',
    required => 1,
);
has db => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_db',
);
sub _build_db {
    my $self = shift;

    return Challenge::Graph::DB->new( $self->db_config );
}

sub queries {
    die "should be implimented by subclass";
}
sub graph_id {
    die "should be implimented by subclass";
}
sub answers {
    die "should be implimented by subclass";
}

#some output formats (JSON) has true booleans, but perl doesn't
# so make this overridable
sub false { 0 }
sub _solve {
    my $self = shift;

    my $graph = $self->db->load( $self->graph_id );

    my @answers;
    foreach my $queries ( @{$self->queries} ) {
        foreach my $query ( @{$queries} ) {
            if ( $query->method eq 'cheapest' ) {
                my $result = $graph->cheapest( $query->start, $query->end );

                my $answer = {
                    cheapest => {
                        path  => $result || $self->false,
                        from  => $query->start,
                        to    => $query->end,
                    }
                };

                push @answers, $answer;
            }
            if ( $query->method eq 'paths' ) {
                my $result = $graph->paths( $query->start, $query->end );
                my $answer = {
                    paths => {
                        paths => $result,
                        from  => $query->start,
                        to    => $query->end,
                    }
                };
                push @answers, $answer;
            }
        }
    }

    return\@answers;
}

__PACKAGE__->meta->make_immutable;
