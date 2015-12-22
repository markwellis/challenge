use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Config::ZOMG;

use JSON::MaybeXS;
use Challenge::Graph::DB;

#no one likes hard-coded config options
my $config = Config::ZOMG->open(
    name => 'challenge',
    path => "$Bin/..",
) || die "couldn't load config file\n";

my $json_encoder = JSON::MaybeXS->new(utf8 => 1);

my $stdin = join "", <>;
my $json = $json_encoder->decode( $stdin );

#must be at least one queries
# query must have a graph id
# query must have a cheapest or path
die "not an object\n" if ref $json ne 'HASH';
die "no queries provided\n"
    if !exists $json->{queries};
die "queries needs to be an array\n"
    if ref $json->{queries} ne 'ARRAY';
die "there needs to be at least one query\n"
    if !scalar @{$json->{queries}};

my %graph_cache;
print "connecting to db\n";
my $graph_db = Challenge::Graph::DB->new( $config->{db} );

my @answers;
foreach my $query ( @{$json->{queries}} ) {
    die "query needs to be an object\n"
        if ref $query ne "HASH";

    if ( !exists $query->{paths} && !exists $query->{cheapest} ) {
        die "query needs a 'paths' or 'cheapest'\n";
    }
    if ( !exists $query->{graph_id} ) {
        die "query needs a 'graph_id'\n";
    }

    #XXX this can go once there's moo objects
    foreach my $method ( qw/paths cheapest/ ) {
        if ( exists $query->{ $method } ) {
            die "$method has no start\n"
                if !exists $query->{ $method }->{start};

            die "$method has no end\n"
                if !exists $query->{ $method }->{end};
        }
    }
    #XXX
    #
    my $graph;
    if ( exists $graph_cache{ $query->{graph_id} } ) {
        $graph = $graph_cache{ $query->{graph_id} };
    }
    else {
        $graph = $graph_db->load( $query->{graph_id } );
        die "no graph " . $query->{graph_id} . " found\n" if !$graph;
        $graph_cache{ $query->{graph_id} } = $graph;
    }

    if ( exists $query->{cheapest} ) {
        my $start = $query->{cheapest}->{start};
        my $end = $query->{cheapest}->{end};
        push @answers, {
            cheapest => {
                from    => $start,
                to      => $end,
                path    => $graph->cheapest( $start, $end ) || JSON->false,
            }
        };
    }

    if ( exists $query->{paths } ) {
        my $start = $query->{paths}->{start};
        my $end = $query->{paths}->{end};
        push @answers, {
            paths => {
                from    => $start,
                to      => $end,
                paths   => $graph->paths( $start, $end ) || !!0,
            }
        };
    }
}

print $json_encoder->encode( { answers => \@answers } );
