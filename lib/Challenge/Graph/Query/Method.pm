package Challenge::Graph::Query::Method;
use Moo;
use Types::Standard qw/Str/;

has method => (
    is          => 'ro',
    isa         => Str,
    required    => 1,
);

has start => (
    is          => 'ro',
    isa         => Str,
    required    => 1,
);

has end => (
    is          => 'ro',
    isa         => Str,
    required    => 1,
);

__PACKAGE__->meta->make_immutable;
