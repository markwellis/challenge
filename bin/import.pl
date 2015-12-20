use strict;
use warnings;
use v5.10;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use LWP::UserAgent;
use Getopt::Long;
use DBI;
use Config::ZOMG;
use Challenge::GraphXML;
use Try::Tiny;

my $config = Config::ZOMG->open(
    name => 'challenge',
    path => "$Bin/..",
) || die "couldn't load config file\n";

my %options;
GetOptions (
    \%options,
    "xml_url=s",
    "replace",
) || die "need xml_url\n";

my $dbh = connect_to_db( $config->{db} );

main();
$dbh->disconnect;

sub main {
    my $xml = fetch_xml( $options{xml_url} );
    my $graph = parse_xml( $xml );
    save_graph( $graph );
}

sub graph_exists {
    my $graph = shift;

    my $sth = $dbh->prepare( 'SELECT 1 FROM "graphs" WHERE "id" = ?' ) ;
    $sth->execute( $graph->id );

    if ( $sth->rows ) {
        return 1;
    }

    return;
}

sub delete_existing_graph {
    my $graph = shift;

    my $delete_edges = $dbh->prepare( 'DELETE FROM "edges" WHERE "graph_id" = ?' ) ;
    my $delete_nodes = $dbh->prepare( 'DELETE FROM "nodes" WHERE "graph_id" = ?' ) ;
    my $delete_graph = $dbh->prepare( 'DELETE FROM "graphs" WHERE "id" = ?' ) ;

    $delete_edges->execute( $graph->id );
    $delete_nodes->execute( $graph->id );
    $delete_graph->execute( $graph->id );
}

sub save_graph {
    my $graph = shift;

    try {
        if ( graph_exists( $graph ) ) {
            if ( $options{replace} ) {
                say "deleting existing graph ", $graph->id;
                delete_existing_graph( $graph );
            }
            else {
                die "graph ", $graph->id, " already exists\n";
            }
        }

        #prepare some statements
        my $insert_graph = $dbh->prepare(
            'INSERT INTO "graphs" ( "id", "name" ) VALUES ( ?, ? )'
        );
        my $insert_node = $dbh->prepare(
            'INSERT INTO "nodes" ( "graph_id", "id", "name" ) VALUES ( ?, ?, ? )'
        );
        my $insert_edge = $dbh->prepare(
            'INSERT INTO "edges" ( "graph_id", "id", "to", "from", "cost" ) VALUES ( ?, ?, ?, ?, ? )'
        );

        say "saving graph ", $graph->id;

        #insert
        $insert_graph->execute( $graph->id, $graph->name );
        foreach my $node ( @{$graph->nodes} ) {
            $insert_node->execute( $graph->id, $node->{id}, $node->{name} );
        }
        foreach my $edge ( @{$graph->edges} ) {
            $insert_edge->execute( $graph->id, $edge->{id}, $edge->{to}, $edge->{from}, $edge->{cost} );
        }

        $dbh->commit;
    }
    catch {
        $dbh->rollback   or die $dbh->errstr;
        die "insert failed: $_";
    };
}

sub connect_to_db {
    my $options = shift;

    #usually, I'd use the DBIx::Class ORM, because it makes dealing
    # with the db far simpler, but it'll overcomplicate things
    my $attrs = {
        %{$options->{attrs}},
        RaiseError => 1,        #so we can handle errors better
        AutoCommit => 0,        #recommended
    };

    my $dbh = DBI->connect(
        $options->{dsn},
        $options->{username},
        $options->{password},
        $attrs,
    );

    return $dbh;
}

sub fetch_xml {
    my $url = shift;

    say "fetching xml";
    my $ua = LWP::UserAgent->new;
    my $response = $ua->get( $url );

    if ( !$response->is_success ) {
        die "failed to fetch xml $url", $response->status_line, "\n";
    }

    return $response->decoded_content;
}

sub parse_xml {
    my $xml = shift;

    say "parsing xml";
    #this will die if the xml is invalid
    my $graph_xml = Challenge::GraphXML->new(
        xml => $xml,
    );

    return $graph_xml->graph;
}
