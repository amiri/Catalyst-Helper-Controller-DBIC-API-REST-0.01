package RestTest::Controller::API::REST::Artist;

use strict;
use warnings;
use base qw/RestTest::ControllerBase::REST/;
use JSON::Syck;

__PACKAGE__->config(
    action                  =>  { setup => { PathPart => 'artist', Chained => '/api/rest/rest_base' } },
                                # define parent chain action and partpath
    class                   =>  'DB::Artist', # DBIC result class
    create_requires         =>  [qw/name/], # columns required to create
    create_allows           =>  [qw//], # additional non-required columns that create allows
    update_allows           =>  [qw/name/], # columns that update allows
    list_returns            =>  [qw/artistid name/], # columns that list returns


    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        [qw/cds/], {  'cds' => [qw/cd_to_producer tags tracks/] },
		
    ],

    list_ordered_by         => [qw/artistid/], # order of generated list
    list_search_exposes     => [
        qw/artistid name/,
        { 'cds' => [qw/cdid artist title year/] },
		
    ], # columns that can be searched on via list
);

=head1 NAME

 - REST Controller for RestTest

=head1 DESCRIPTION

REST Methods to access the DBIC Result Class artist

=head1 AUTHOR

amiri,,,

=head1 SEE ALSO

L<Catalyst::Controller::DBIC::API>
L<Catalyst::Controller::DBIC::API::REST>
L<Catalyst::Controller::DBIC::API::RPC>

=head1 LICENSE



=cut

1;
