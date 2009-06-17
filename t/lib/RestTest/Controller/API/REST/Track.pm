package RestTest::Controller::API::REST::Track;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::REST/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'track', Chained => '/api/rest/rest_base' } },
      class => 'RestTestDB::Track',
      create_requires => ['cd', 'title' ],
      create_allows => ['cd', 'title', 'position' ],
      update_allows => ['title', 'position']
      );

1;
