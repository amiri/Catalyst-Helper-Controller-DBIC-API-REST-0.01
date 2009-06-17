package RestTest::Controller::API::RPC::Track;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'track', Chained => '/api/rpc/rpc_base' } },
      class => 'RestTestDB::Track',
      create_requires => ['cd', 'title' ],
      create_allows => ['cd', 'title', 'position' ],
      update_allows => ['title', 'position', { cd => ['*'] }],
      list_grouped_by => ['position'],
      list_returns => ['position'],
      list_ordered_by => ['position'],
			list_search_allows => ['title']
      );

1;
