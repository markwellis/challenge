requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';

requires 'XML::Twig';

requires 'Cpanel::JSON::XS';
requires 'JSON::MaybeXS';

requires 'Moo';

requires 'DBI';
requires 'DBD::Pg';
requires 'Getopt::Long';

requires 'Config::ZOMG';
requires 'Config::Any::TOML';
requires 'Try::Tiny';

test_requires 'Test::More';
test_requires 'Path::Tiny';

#the worlds greatest debugger!
test_requires 'Data::Dumper::Concise';
