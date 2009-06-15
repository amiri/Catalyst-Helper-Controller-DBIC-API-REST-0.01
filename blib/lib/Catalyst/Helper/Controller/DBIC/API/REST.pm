package Catalyst::Helper::Controller::DBIC::API::REST;

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Data::Dumper;
our $VERSION = '0.01';


sub mk_compclass {
    my ( $self, $helper, $schema_class ) = @_;
    $helper->{schema_class} = $schema_class;
        my $schema_file = "$schema_class\/Schema";
        require "$schema_file.pm";
        my $schema_name = "$schema_class\:\:Schema";
        my $schema = $schema_name->connect;

    for ($schema->sources) {
        my ($list_returns,$class,$result_class);
        $list_returns = join(' ', $schema->source($_)->columns);
        my $file = "$FindBin::Bin/../lib/" . $helper->{app} . "/" . $helper->{type} . "/API/REST/" . $_ . ".pm";
        $class = $helper->{app} . "::" . $helper->{type} . "::API::REST::" . $_;
        $result_class = $helper->{app} . "::" . "Model::DB::" . $_; 
        $helper->{class} = $class;
        $helper->{result_class} = $_;
        $helper->{class_name} = $schema->source_registrations->{$_}->name;
        $helper->{file} = $file;
        $helper->{list_returns} = $list_returns;
        $helper->render_file( 'compclass', $file );
    }
#    print Dumper $schema->sources;



#    print Dumper $helper;
}

1;

=head1 NAME

Catalyst::Helper::Controller::DBIC::API::REST

=head1 SYNOPSIS

    $ catalyst.pl myapp
    $ cd myapp
    $ script/myapp_create.pl controller API::REST::base DBIC::API::REST myapp

=head1 DESCRIPTION

  This creates REST controllers for all the classes in your Catalyst app.

=head1 AUTHOR

Amiri Barksdale E<lt>amiri@metalabel.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__DATA__

__compclass__
package [% class %];

use base 'Catalyst::Controller::DBIC::API::REST';

__PACKAGE__->config(
    action => { setup => { PathPart => '[% class_name  %]', Chained => '/api/rest/rest_base' } }, # define parent chain action and partpath
    class => '[% result_class %]', # DBIC result class
    create_requires => [[% create_requires %]], # columns required to create
    create_allows => [[% create_allows %]], # additional non-required columns that create allows
    update_allows => [[% update_allows %]], # columns that update allows
    list_returns => [qw/[% list_returns %]/], # columns that list returns
    list_prefetch => [[% list_prefetch  %]], # relationships that are prefetched when no prefetch param is passed
    list_prefetch_allows => [ # every possible prefetch param allowed
        qw/[% list_prefetch_allows %]/,
    ],
    list_ordered_by => [qw/[% list_ordered_by %]/], # order of generated list
    list_search_exposes => [qw/[% list_search_exposes %]/], # columns that can be searched on via list
);

=head1 NAME

[% CLASS %] - REST Controller for [% schema_class %]

=head1 DESCRIPTION

REST Methods to access the DBIC Result Class [% class_name %]

=head1 AUTHOR

[% author %]

=head1 SEE ALSO

L<Catalyst::Controller::DBIC::API>
L<Catalyst::Controller::DBIC::API::REST>
L<Catalyst::Controller::DBIC::API::RPC>

=head1 LICENSE

[% license %]

=cut

1;
