package RestTest::Controller::API::REST::Producer;

use strict;
use warnings;
use JSON::XS;

use parent qw/RestTest::ControllerBase::REST/;

__PACKAGE__->config(
    action                  =>  { setup => { PathPart => 'producer', Chained => '/api/rest/rest_base' } },
                                # define parent chain action and partpath
    class                   =>  'DB::Producer', # DBIC result class
    create_requires         =>  [qw/name/], # columns required to create
    create_allows           =>  [qw//], # additional non-required columns that create allows
    update_allows           =>  [qw/name/], # columns that update allows
    list_returns            =>  [qw/producerid name/], # columns that list returns


    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        [qw/cd_to_producer/], {  'cd_to_producer' => [qw//] },
        [qw/tags/], {  'tags' => [qw//] },
        [qw/tracks/], {  'tracks' => [qw//] },

    ],

    list_ordered_by         => [qw/producerid/], # order of generated list
    list_search_exposes     => [
        qw/producerid name/,

    ], # columns that can be searched on via list
);

=head1 NAME

 - REST Controller for

=head1 DESCRIPTION

REST Methods to access the DBIC Result Class producer

=head1 AUTHOR

amiri,,,

=head1 SEE ALSO

L<Catalyst::Controller::DBIC::API>
L<Catalyst::Controller::DBIC::API::REST>
L<Catalyst::Controller::DBIC::API::RPC>

=head1 LICENSE



=cut

1;
