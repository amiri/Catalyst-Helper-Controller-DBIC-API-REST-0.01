package RestTest::Controller::API::RPC::TrackExposed;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'track_exposed', Chained => '/api/rpc/rpc_base' } },
      class => 'RestTestDB::Track',
      list_returns => [qw/position title/],
      list_ordered_by => [qw/position/],
      list_search_exposes => [qw/position/, { cd => [qw/title year pretend/, { artist => ['*'] }] }],
      );

1;
