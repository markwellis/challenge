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

=cut
sub cheapest {
    my ( $self, $start, $end ) = @_;

    #could use an algorithm to search for the cheapest, but map/reduce will work
    # and it'll do for this challenge... i hope!
    my @found_paths = $self->_find_paths( $start, $end );

    my @paths;
    foreach my $path ( @found_paths ) {
        my $cost = sum map { $_->[1] } @$path;

        push @paths, { path => [map { $_->[0] } @$path], cost => $cost };
    }

    my $cheapest = reduce
        { ( $a->{cost} < $b->{cost} ) ? $a->{path} : $b->{path} }
        @paths;

    #!!0 is PL_sv_no, which means json encoding will be false, instead of 0.
    return $cheapest || !!0;
}

=head1 paths( $start, $end )

finds all paths from $start to $end

=cut
sub paths {
    my ( $self, $start, $end ) = @_;

    my @found_paths = $self->_find_paths( $start, $end );

    my @paths;
    #we don't care about costs here, so strip them out
    foreach my $path ( @found_paths ) {
        push @paths, [map { $_->[0] } @$path];
    }

    \@paths;
}

=head1 edges_starting( $from )

finds edges starting from $from

=cut
sub edges_starting {
    my ( $self, $from ) = @_;

    grep { $_->{from} eq $from } @{$self->edges}
}

#internal method, finds all the edges in a path
# returns an arrayref of arraryrefs which contain arrayrefs[$node_id, $cost)
# e.g
# [
#  [
#   [
#    'a',
#    12
#   ],
#   [
#    'b',
#    0,
#   ]
#  ]
# ]
sub _find_paths {
    my ( $self, $start, $end ) = @_;

    my @paths;
    foreach my $edge ( $self->edges_starting( $start ) ) {
        my @resolved_path = $self->_resolve_path( $edge );
        next if ( $resolved_path[-1]->[0] ne $end );

        push @paths, \@resolved_path;
    }

    @paths;
}

#internal method, resolves a starting edge to a full path
sub _resolve_path {
    my ( $self, $edge ) = @_;

    #follow all edges from => to
    #this doesn't work with branches
    my @path = ( [$edge->{from}, $edge->{cost}] );
    while ( $edge ) {
        #ignore cycles
        last if any { $_->[0] eq $edge->{to} } @path;

        push @path, [$edge->{to}, $edge->{cost}];
        my @edges = $self->edges_starting( $edge->{to} );
        my $count = scalar @edges;

        last if !$count;

        #XXX this doesn't work with branches
        $edge = $edges[0];
    }

    @path;
}

__PACKAGE__->meta->make_immutable;
