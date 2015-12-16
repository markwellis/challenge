package Challenge::Graph::Node;
use Moo;
use Types::Standard -types;

has graph => (
    is       => 'ro',
    required => 1,
    weak_ref => 1,
);

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

__PACKAGE__->meta->make_immutable;
