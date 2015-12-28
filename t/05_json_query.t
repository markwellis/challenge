use strict;
use warnings;
use Test::More tests => 3;
use Path::Tiny;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Challenge::Graph::Query::JSON;

subtest "no graph_id" => sub {
    plan tests => 2;

    my $json = path("$Bin/test_queries/no_graph_id.json")->slurp_utf8;

    eval {
        my $json_query = Challenge::Graph::Query::JSON->new(
            json        => $json,
            db_config   => {},
        );
    };

    like
        $@,
        qr/invalid json/i,
        "error: invalid json";
    like
        $@,
        qr/\Qgraph_id: is missing and it is required\E/i,
        "error: no graph id";
};

subtest "missing required keys" => sub {
    plan tests => 4;

    my $json = path("$Bin/test_queries/invalid_scheme.json")->slurp_utf8;

    eval {
        my $json_query = Challenge::Graph::Query::JSON->new(
            json        => $json,
            db_config   => {},
        );
    };

    like
        $@,
        qr/invalid json/i,
        "error: invalid json";
    like $@,
        qr/\Qgraph_id: is missing and it is required\E/i,
        "error: no graph id";
    like $@,
        qr/\Q.queries.1.cheapest.end: is missing and it is required\E/i,
        "error: no cheapest.end";
    like $@,
        qr/\Q.queries.2.paths.start: is missing and it is required\E/i,
        "error: no paths.start";
};

subtest 'valid' => sub {
    plan tests => 5;

    my $json = path("$Bin/test_queries/valid.json")->slurp_utf8;

    my $json_query = Challenge::Graph::Query::JSON->new(
        json        => $json,
        db_config   => {},
    );

    is $json_query->graph_id, 'g0', 'correct graph_id';
    is scalar @{$json_query->queries}, 3, 'correct amount of queries';

    subtest 'first query' => sub {
        plan tests => 4;

        is scalar @{$json_query->queries->[0]}, 1, 'correct amount of methods';
        my $query = $json_query->queries->[0]->[0];

        is $query->start, 'a', 'correct start';
        is $query->end, 'e', 'correct end';
        is $query->method, 'paths', 'correct method';
    };
    subtest 'second query' => sub {
        plan tests => 4;

        is scalar @{$json_query->queries->[1]}, 1, 'correct amount of methods';
        my $query = $json_query->queries->[1]->[0];

        is $query->start, 't', 'correct start';
        is $query->end, 'g', 'correct end';
        is $query->method, 'cheapest', 'correct method';
    };

    subtest 'third query' => sub {
        plan tests => 2;

        is scalar @{$json_query->queries->[2]}, 2, 'correct amount of methods';
        my $parsed = {};
        #since we can't guarentee the order, we'll use a hash to check the parsed data
        foreach my $query ( @{$json_query->queries->[2]} ) {
            $parsed->{ $query->method } = [ $query->start, $query->end ];
        }
        my $expected = {
            paths    => [qw/c a/],
            cheapest => [qw/b d/],
        };
        is_deeply $parsed, $expected, 'correct data';
    };
};
