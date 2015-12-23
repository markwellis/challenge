package Challenge::Graph::Query::JSON;
use Moo;

extends qw/Challenge::Graph::Query/;

use Challenge::Graph::Query::Method;
use JSON::MaybeXS qw//;
use Types::Standard qw/ArrayRef HashRef Str Bool/;
use JSON::Schema;

#perl has a PL_sv_no, which for some reason 
# the JSON modules ignore, they have their own way of making false
sub false { JSON::MaybeXS->JSON->false }

has pretty => (
    is      => 'rw',
    isa     => Bool,
    default => sub { 0 },
);
has _json_encoder => (
    is      => 'ro',
    lazy    => 1,
    builder => '_build_json_encoder',
);
sub _build_json_encoder {
    my $self = shift;

    return JSON::MaybeXS->new(
        utf8    => 1,
        pretty  => $self->pretty,
    );
}

has _json => (
    is       => 'ro',
    init_arg => 'json',
    required => 1,
    isa      => sub {
        my $json = shift;

        #this is not quite real json-schema
        my $query_schema = {
            type       => 'object',
            properties => {
                graph_id => {
                    type     => "string",
                    required => 1
                },
                queries => {
                    type     => 'array',
                    required => 1,
                    items    => {
                        type       => 'object',
                        properties => {
                            paths => {
                                type       => 'object',
                                properties => {
                                    start => {
                                        type     => 'string',
                                        required => 1,
                                    },
                                    end   => {
                                        type     => 'string',
                                        required => 1,
                                    },
                                },
                            },
                            cheapest => {
                                type       => 'object',
                                properties => {
                                    start => {
                                        type     => 'string',
                                        required => 1,
                                    },
                                    end   => {
                                        type     => 'string',
                                        required => 1,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        };

        my $validator = JSON::Schema->new( $query_schema );
        my $valid = $validator->validate( $json );

        return if $valid;

        my $errors = join "\n  ", $valid->errors;
        die "invalid json request\n  $errors\n";
    },
);
has json => (
    is       => 'ro',
    isa      => HashRef,
    init_arg => undef,
    lazy     => 1,
    builder  => '_build_json',
);
sub _build_json {
    my $self = shift;

    return $self->_json_encoder->decode( $self->_json );
}

has graph_id => (
    is      => 'ro',
    isa     => Str,
    lazy    => 1,
    builder => '_build_graph_id',
);
sub _build_graph_id {
    my $self = shift;

    $self->json->{graph_id};
}

has queries => (
    is      => 'ro',
    isa     => ArrayRef[ArrayRef],
    lazy    => 1,
    builder => '_build_queries',
);
sub _build_queries {
    my $self = shift;

    my @queries;

    foreach my $query ( @{$self->json->{queries}} ) {
        my @parts;

        for my $method ( qw/cheapest paths/ ) {
            if ( exists $query->{$method} ) {
                push @parts, Challenge::Graph::Query::Method->new(
                    method => $method,
                    start  => $query->{$method}->{start},
                    end    => $query->{$method}->{end},
                );
            }
        }

        push @queries, \@parts;
    }


    \@queries;
}

sub answers {
    my $self = shift;

    return $self->_json_encoder->encode(
        {
            answers => $self->_solve
        }
    );
}

__PACKAGE__->meta->make_immutable;
