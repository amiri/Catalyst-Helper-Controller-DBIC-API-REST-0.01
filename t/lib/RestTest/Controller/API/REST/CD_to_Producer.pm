package RestTest::Controller::API::REST::CD_to_Producer;

use strict;
use warnings;
use base qw/RestTest::ControllerBase::REST/;
use JSON::Syck;

__PACKAGE__->config(
    action                  =>  { setup => { PathPart => 'cd_to_producer', Chained => '/api/rest/rest_base' } },
                                # define parent chain action and partpath
    class                   =>  'DB::CD_to_Producer', # DBIC result class
    create_requires         =>  [qw/cd producer/], # columns required to create
    create_allows           =>  [qw//], # additional non-required columns that create allows
    update_allows           =>  [qw/cd producer/], # columns that update allows
    list_returns            =>  [qw/cd producer/], # columns that list returns


    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        [qw/cd_to_producer/], {  'cd_to_producer' => [qw//] },
		[qw/tags/], {  'tags' => [qw//] },
		[qw/tracks/], {  'tracks' => [qw//] },
		
    ],

    list_ordered_by         => [qw/cd producer/], # order of generated list
    list_search_exposes     => [
        qw/cd producer/,
        
    ], # columns that can be searched on via list
);

=head1 NAME

 - REST Controller for RestTest

=head1 DESCRIPTION

REST Methods to access the DBIC Result Class cd_to_producer

=head1 AUTHOR

amiri,,,

=head1 SEE ALSO

L<Catalyst::Controller::DBIC::API>
L<Catalyst::Controller::DBIC::API::REST>
L<Catalyst::Controller::DBIC::API::RPC>

=head1 LICENSE



=cut

1;
