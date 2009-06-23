package RestTest::Controller::API::REST::CD;

use strict;
use warnings;
use base qw/RestTest::ControllerBase::REST/;
use JSON::Syck;

__PACKAGE__->config(
    action                  =>  { setup => { PathPart => 'cd', Chained => '/api/rest/rest_base' } },
                                # define parent chain action and partpath
    class                   =>  'DB::CD', # DBIC result class
    create_requires         =>  [qw/artist title year/], # columns required to create
    create_allows           =>  [qw//], # additional non-required columns that create allows
    update_allows           =>  [qw/artist title year/], # columns that update allows
    list_returns            =>  [qw/cdid artist title year/], # columns that list returns
    list_prefetch           =>  [qw//], # relationships that are prefetched
                                                            # when no prefetch param is passed
    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        'cd_to_producer', { cd_to_producer => [qw//] },
		'tags', { tags => [qw//] },
		'tracks', { tracks => [qw//] },
		
    ],
    list_ordered_by         => [qw/cdid/], # order of generated list
    list_search_exposes     => [qw/cdid artist title year/], # columns that can be searched on via list
);

=head1 NAME

 - REST Controller for RestTest

=head1 DESCRIPTION

REST Methods to access the DBIC Result Class cd

=head1 AUTHOR

amiri,,,

=head1 SEE ALSO

L<Catalyst::Controller::DBIC::API>
L<Catalyst::Controller::DBIC::API::REST>
L<Catalyst::Controller::DBIC::API::RPC>

=head1 LICENSE



=cut

1;

