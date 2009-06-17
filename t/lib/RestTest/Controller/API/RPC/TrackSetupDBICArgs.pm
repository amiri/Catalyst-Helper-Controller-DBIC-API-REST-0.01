package RestTest::Controller::API::RPC::TrackSetupDBICArgs;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::RPC/;
use JSON::Syck;

__PACKAGE__->config
    ( action => { setup => { PathPart => 'track_setup_dbic_args', Chained => '/api/rpc/rpc_base' } },
      class => 'RestTestDB::Track',
      list_returns => [qw/position title/],
      list_ordered_by => [qw/position/],
			setup_dbic_args_method => 'setup_dbic_args'
      );

sub setup_dbic_args : Private {
	my ($self, $c, $params, $args) = @_;

	$params->{position} = { '!=' => '1' };
	return [$params, $args];
}

1;
