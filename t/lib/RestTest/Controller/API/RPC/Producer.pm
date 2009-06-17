package RestTest::Controller::API::RPC::Producer;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'producer', Chained => '/api/rpc/rpc_base' } },
      class => 'RestTestDB::Producer',
      create_requires => ['name'],
      update_allows => ['name'],
      list_returns => ['name']
      );

sub create :Chained('setup') :Args(0) :PathPart('create') {
  my ($self, $c) = @_;
  $self->next::method($c);

  if ($c->stash->{created_object}) {
    %{$c->stash->{response}->{new_producer}} = $c->stash->{created_object}->get_columns;
  }
}

1;
