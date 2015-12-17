package Challenge::Graph;
use Moo;

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
    isa      => sub { die "nodes should be an arrayref" if !ref $_ eq 'ARRAY' },
);
has edges => (
    is       => 'ro',
    required => 1,
    default  => sub { [] },
);

sub cheapest {
    my ( $self, $start, $end ) = @_;
}

sub paths {
    my ( $self, $start, $end ) = @_;
}

__PACKAGE__->meta->make_immutable;
