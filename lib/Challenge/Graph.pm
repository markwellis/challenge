package Challenge::Graph;
use Moo;
use Types::Standard -types;

has id => (
    is       => 'ro',
    required => 1,
    isa      => Str,
);
has name => (
    is       => 'ro',
    required => 1,
    isa      => Str,
);

has nodes => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef, #XXX make this array of Challenge::Graph::Node, and coerce
);
has edges => (
    is       => 'ro',
    required => 1,
    isa      => ArrayRef, #XXX make this array of Challenge::Graph::Edge, and coerce
);

sub validate {
    die 'invalid';
}

__PACKAGE__->meta->make_immutable;
