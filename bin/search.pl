use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use Config::ZOMG;

use Challenge::Graph::DB;
use Challenge::Graph::Query::JSON;

#no one likes hard-coded config options
my $config = Config::ZOMG->open(
    name => 'challenge',
    path => "$Bin/..",
) || die "couldn't load config file\n";

my $stdin = join "", <>;
my $query = Challenge::Graph::Query::JSON->new(
    json        => $stdin,
    db_config   => $config->{db},
    pretty      => 1, #human readable json
);

print $query->answers;
