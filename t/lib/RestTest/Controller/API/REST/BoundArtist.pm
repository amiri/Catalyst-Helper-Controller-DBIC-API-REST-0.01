package RestTest::Controller::API::REST::BoundArtist;

use strict;
use warnings;
use base qw/RestTest::Controller::API::REST::Artist/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'bound_artist', Chained => '/api/rest/rest_base' } },
      class => 'RestTestDB::Artist',
      setup_list_method => 'filter_search',
      create_requires => ['name'],
      create_allows => ['name'],
      update_allows => ['name']
      );

# Arbitrary limit
sub filter_search : Private {
    my ( $self, $c, $query ) = @_;
    # Return the first one, regardless of what comes in via params
    $query->{search}->{'artistid'} = 1;
}

1;
