package RestTest::Controller::API::RPC::Any;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

sub setup :Chained('/api/rpc/rpc_base') :CaptureArgs(1) :PathPart('any') {
  my ($self, $c, $object_type) = @_;

  my $config = {};
  if ($object_type eq 'artist') {
    $config->{class} = 'Artist';
    $config->{create_requires} = [qw/name/];
    $config->{update_allows} = [qw/name/];
  } elsif ($object_type eq 'track') {
    $config->{class} = 'Track';
    $config->{update_allows} = [qw/title position/];
  } else {
    $self->push_error($c, { message => "invalid object_type" });
    return;
  }

  $c->stash->{$self->rs_stash_key} = $c->model('RestTestDB::' . $config->{class});
  $c->stash->{$_} = $config->{$_} for keys %{$config};
}

1;
