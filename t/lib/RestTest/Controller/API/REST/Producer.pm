package RestTest::Controller::API::REST::Producer;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::REST/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'producer', Chained => '/api/rest/rest_base' } },
      class => 'RestTestDB::Producer',
      create_requires => ['name'],
      update_allows => ['name'],
      list_returns => ['name']
      );

sub create :Private {
  my ($self, $c) = @_;
  $self->next::method($c);

  if ($c->stash->{created_object}) {
    %{$c->stash->{response}->{new_producer}} = $c->stash->{created_object}->get_columns;
  }
}

1;
