package RestTest::Controller::API::RPC::CD;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'cd', Chained => '/api/rpc/rpc_base' } },
      class => 'RestTestDB::CD',
      create_requires => ['artist', 'title', 'year' ],
      update_allows => ['title', 'year']
      );

1;
