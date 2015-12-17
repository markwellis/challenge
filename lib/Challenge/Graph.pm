package Challenge::Graph;
use Moo;
use List::Util qw/first any/;

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

sub cheapest {
    my ( $self, $start, $end ) = @_;

    0;
}

sub paths {
    my ( $self, $start, $end ) = @_;

    my @paths;
    foreach my $edge ( $self->edges_starting( $start ) ) {
        my @resolved_path = $self->resolve_path( $edge );
        next if ( $resolved_path[-1] ne $end );
        push @paths, \@resolved_path;
    }

    \@paths;
}
sub edges_starting {
    my ( $self, $from ) = @_;

    grep { $_->{from} eq $from } @{$self->edges}
}

sub resolve_path {
    my ( $self, $edge ) = @_;

    #follow all edges from => to
    #this doesn't work with branches
    my @path = ( $edge->{from} );
    while ( $edge ) {
        #handle cycles
        return [] if any { $_ eq $edge->{to} } @path;

        push @path, $edge->{to};
        my @edges = $self->edges_starting( $edge->{to} );

        #XXX this doesn't work with branches
        $edge = $edges[0];
    }

    @path;
}

__PACKAGE__->meta->make_immutable;
