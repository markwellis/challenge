package Challenge::Graph::Query;
use Moo;

use Challenge::Graph::Query::Path;
use Challenge::Graph::Query::Cheapest;
use JSON::MaybeXS qw//;
use Types::Standard qw/ArrayRef HashRef/;
use JSON::Schema;

has json => (
    is       => 'ro',
    init_arg => 'json',
    required => 1,
    coerce   => sub {
        my $json = shift;

        #isa checks are not ran for coerce, so we have to validate here
        my $schema = {
            '$schema'  => "http://json-schema.org/draft-04/schema#",
            type       => 'object',
            properties => {
                queries => {
                    type            => 'array',
                    items           => { '$ref' => "#/definitions/query" },
                    additionalItems => { '$ref' => "#/definitions/query" },
                },
            },
            definitions => {
                query => {
                    type       => 'object',
                    properties => {
                        graph_id => { type   => "string" },
                        paths    => { '$ref' => "#/definitions/start_end" },
                        cheapest => { '$ref' => "#/definitions/start_end" },
                        required => [ qw/graph_id/ ],
                    }
                },
                start_end => {
                    type       => 'object',
                    properties => {
                        start => { type => 'string' },
                        end   => { type => 'string' },
                    },
                    required => [ qw/start end/ ],
                }
            },
            required => [ qw/queries/ ],
        };

        my $validator = JSON::Schema->new( $schema );
        my $valid = $validator->validate( $json );

        if ( $valid ) {
            return JSON::MaybeXS::decode_json( $json );
        }

        my $errors = join "\n  ", $valid->errors;
        die "invalid json format\n  $errors\n";
    },
);

has queries => (
    is      => 'ro',
    isa     => ArrayRef,
    lazy    => 1,
    builder => '_build_queries',
);
sub _build_queries {
    my $self = shift;

    foreach my $query ( @{$self->json->queries} ) {
use Data::Dumper::Concise;
warn Dumper( $query );
    }
}

__PACKAGE__->meta->make_immutable;
