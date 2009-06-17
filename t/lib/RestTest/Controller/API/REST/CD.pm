package RestTest::Controller::API::REST::CD;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::REST/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'cd', Chained => '/api/rest/rest_base' } },
      class => 'RestTestDB::CD',
      create_requires => ['artist', 'title', 'year' ],
      update_allows => ['title', 'year']
      );

1;
