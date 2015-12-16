package Challenge::Graph::Edge;
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
has from => (
    is       => 'ro',
    required => 1,
    isa      => Str,
);
has to => (
    is       => 'ro',
    required => 1,
    isa      => Str,
);

has cost => (
    is       => 'ro',
    isa      => Num, #XXX check this is >0
    default  => 0,
);

__PACKAGE__->meta->make_immutable;
