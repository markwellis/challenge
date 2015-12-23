package Challenge::Graph::Query::Cheapest;
use Moo;

has graph_id => (
    is          => 'ro',
    required    => 1,
);
has start => (
    is          => 'ro',
    required    => 1,
);
has end => (
    is          => 'ro',
    required    => 1,
);

__PACKAGE__->meta->make_immutable;
