package RestTest::Controller::API::REST::Track;

use strict;
use warnings;
use base qw/RestTest::ControllerBase::REST/;
use JSON::Syck;

__PACKAGE__->config(
    action                  =>  { setup => { PathPart => 'track', Chained => '/api/rest/rest_base' } },
                                # define parent chain action and partpath
    class                   =>  'DB::Track', # DBIC result class
    create_requires         =>  [qw/cd position title/], # columns required to create
    create_allows           =>  [qw/last_updated_on/], # additional non-required columns that create allows
    update_allows           =>  [qw/cd position title last_updated_on/], # columns that update allows
    list_returns            =>  [qw/trackid cd position title last_updated_on/], # columns that list returns


    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        [qw/cd_to_producer/], {  'cd_to_producer' => [qw//] },
		[qw/tags/], {  'tags' => [qw//] },
		[qw/tracks/], {  'tracks' => [qw//] },
		
    ],

    list_ordered_by         => [qw/trackid/], # order of generated list
    list_search_exposes     => [
        qw/trackid cd position title last_updated_on/,
        
    ], # columns that can be searched on via list
);

=head1 NAME

 - REST Controller for RestTest

=head1 DESCRIPTION

REST Methods to access the DBIC Result Class track

=head1 AUTHOR

amiri,,,

=head1 SEE ALSO

L<Catalyst::Controller::DBIC::API>
L<Catalyst::Controller::DBIC::API::REST>
L<Catalyst::Controller::DBIC::API::RPC>

=head1 LICENSE



=cut

1;
