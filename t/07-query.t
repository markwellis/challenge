use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Config::ZOMG;
use Test::More tests => 6;
use JSON::MaybeXS;
use Path::Tiny;

use Challenge::Graph::DB;
use Challenge::Graph::XML;
use Challenge::Graph::Query::JSON;

#no one likes hard-coded config options
my $config = Config::ZOMG->open(
    name => 'challenge',
    path => "$Bin/..",
) || die "couldn't load config file\n";

my $graph_db = Challenge::Graph::DB->new( $config->{db} );

my $xml = path("$Bin/test_data/07/graph.xml")->slurp_utf8;
my $graph_xml = Challenge::Graph::XML->new( xml => $xml );
my $graph = $graph_xml->graph;

cleanup();
$graph_db->save( $graph );
END {
    cleanup();
}

my $json = path("$Bin/test_data/07/query.json")->slurp_utf8;
my $query = Challenge::Graph::Query::JSON->new(
    json        => $json,
    db_config   => $config->{db},
);

my $answers = decode_json( $query->answers );
is scalar @{$answers->{answers}}, 3, "correct answer count";

subtest 'first answer' => sub {
    plan tests => 3;

    my $answer = $answers->{answers}->[0];
    is $answer->{paths}->{from}, 'a', 'correct paths from';
    is $answer->{paths}->{to}, 'e', 'correct paths from';

    compare_paths(
        $answer->{paths}->{paths},
        [qw/abdce abde abce/],
    );
};

subtest 'second answer' => sub {
    plan tests => 3;

    my $answer = $answers->{answers}->[1];
    is $answer->{cheapest}->{from}, 'a', 'correct cheapest from';
    is $answer->{cheapest}->{to}, 'c', 'correct cheapest from';

    is_deeply
        $answer->{cheapest}->{path},
        [qw/a b c/],
        'correct answer'
};

subtest 'third answer' => sub {
    plan tests => 7;

    my $answer = $answers->{answers}->[2];

    is $answer->{cheapest}->{from}, 'e', 'correct cheapest from';
    is $answer->{cheapest}->{to}, 'd', 'correct cheapest from';

    is $answer->{paths}->{from}, 'e', 'correct paths from';
    is $answer->{paths}->{to}, 'c', 'correct paths from';

    is ref $answer->{cheapest}->{path}, "JSON::PP::Boolean", "cheapest path is json boolena";
    ok !$answer->{cheapest}->{path}, "cheapest path is false";

    is_deeply
        $answer->{paths}->{paths},
        [],
        "paths is empty";
};

sub compare_paths {
    my ( $answer, $expected ) = @_;

    my $data = {};
    foreach ( @{$answer} ) {
        my $key = join '', @{$_};
        $data->{ $key } = 1;
    }
    is_deeply
        $data,
        {map { $_ => 1 } @$expected},
        'correct answer';
}

sub cleanup {
    $graph_db->delete( 'test07' );
    ok !$graph_db->load( 'test07' ), "no test graph";
}
