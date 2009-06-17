package RestTest::Controller::API::RPC::Artist;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'artist', Chained => '/api/rpc/rpc_base' } },
      class => 'RestTestDB::Artist',
      create_requires => ['name'],
      create_allows => ['name'],
      update_allows => ['name'],
      list_prefetch_allows => [[qw/ cds /],{ 'cds' => 'tracks'}],
      );

1;
