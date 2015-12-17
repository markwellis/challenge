package Challenge::Graph;
use Moo;
use List::Util qw/first any sum reduce/;

has name => (
    is       => 'ro',
    required => 1,
);
has id => (
    is       => 'ro',
    required => 1,
);
has nodes => (
    is       => 'ro',
    required => 1,
    isa      => sub { die "not an arrayref" if !ref $_ eq 'ARRAY' },
);
has edges => (
    is       => 'ro',
    required => 1,
    isa      => sub { die "not an arrayref" if !ref $_ eq 'ARRAY' },
    default  => sub { [] },
);

=head1 cheapest( $start, $end )

finds the cheapest path from $start to $end

returns an arrayref or false

=cut
sub cheapest {
    my ( $self, $start, $end ) = @_;

    #could use an algorithm to search for the cheapest, but we already have
    # the data, so map/reduce will work well enough for this challenge... i hope!
    my @found_paths = $self->_find_paths( $start, $end );

    my $cheapest = reduce
        { ( $a->{cost} < $b->{cost} ) ? $a : $b }
        @found_paths;

    my $path;
    if ( $cheapest ) {
        $path = $cheapest->{path};
    }
    #!!0 is PL_sv_no, which means json encoding will be false, instead of 0.
    return $path || !!0;
}

=head1 paths( $start, $end )

finds all paths from $start to $end

=cut
sub paths {
    my ( $self, $start, $end ) = @_;

    my @found_paths = $self->_find_paths( $start, $end );

    my @paths;
    foreach my $found_path ( @found_paths ) {
        push @paths, $found_path->{path};
    }

    \@paths;
}

=head1 edges_starting( $from )

finds edges starting from $from

returns an arrayref of pathparts

=cut
sub edges_starting {
    my ( $self, $from ) = @_;

    grep { $_->{from} eq $from } @{$self->edges}
}

#internal method, finds all the edges in a path
# returns an arrayref of hashrefs
# e.g.
# [
#   {
#     cost => 1,
#     path => [
#       "a",
#       "b",
#       "c"
#     ]
#   },
#   {
#     cost => 0,
#     path => [
#       "a",
#       "c"
#     ]
#   }
# ]
sub _find_paths {
    my ( $self, $start, $end ) = @_;

    my @paths;
    foreach my $edge ( $self->edges_starting( $start ) ) {
        my @found_edges = $self->_search_edges( $edge, $end );
        foreach my $edges ( @found_edges ) {
            my @path;
            my $cost = sum map { $_->{cost} } @$edges;
            push @path, map { $_->{from} } @$edges;

            #add in the final part of the path, that's not a "from" but a "to"
            push @path, $edges->[-1]->{to};

            push @paths, {
                path    => \@path,
                cost    => $cost
            };
        }
    }

    @paths;
}

#depth first search
sub _search_edges {
    my ( $self, $edge, $end, $seen, @path ) = @_;

    $seen //= {};

    if ( $edge->{from} eq $end ) {
        return \@path;
    }

    #this could be the last part, so make sure it's in the path
    push @path, $edge;
    if ( $edge->{to} eq $end ) {
        return \@path;
    }

    my @paths;

    #record that we've seen this node
    $seen->{ $edge->{from} }++;
    foreach my $next_edge ( $self->edges_starting( $edge->{to} ) ) {
        #prevent cycles if we've seen the node we're going to
        next if $seen->{ $next_edge->{to} };

        my @newpaths = $self->_search_edges( $next_edge, $end, $seen, @path );
        push @paths, @newpaths;
    }

    @paths;
}

__PACKAGE__->meta->make_immutable;
