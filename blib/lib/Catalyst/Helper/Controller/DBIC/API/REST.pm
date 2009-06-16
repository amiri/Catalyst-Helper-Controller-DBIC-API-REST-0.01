package Catalyst::Helper::Controller::DBIC::API::REST;

use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
our $VERSION = '0.01';

sub mk_compclass {
    my ( $self, $helper, $schema_class ) = @_;
    $helper->{schema_class} = $schema_class;

        ## Connect to schema for class info
        my $schema_file = "$schema_class\/Schema";
        require "$schema_file.pm";
        my $schema_name = "$schema_class\:\:Schema";
        my $schema = $schema_name->connect;
        
        ## Make api base
        my $api_file = "$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/"
                        . $helper->{type}
                        . "/API.pm";
        (my $api_path = $api_file) =~ s/\.pm$//;
        $helper->mk_dir($api_path);
        $helper->render_file('apibase', $api_file);
        
        ## Make rest base
        my $rest_file = "$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/"
                        . $helper->{type}
                        . "/API/REST.pm";
        (my $rest_path = $rest_file) =~ s/\.pm$//;
        $helper->mk_dir($rest_path);
        $helper->render_file('restbase', $rest_file);
    
        ## Make result class controllers
        for my $source ($schema->sources) {
            my ($class,$result_class);
            my $file = "$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/" . $helper->{type}
                        . "/API/REST/"
                        . $source
                        . ".pm";
            $class = $helper->{app}
                        . "::"
                        . $helper->{type}
                        . "::API::REST::"
                        . $source;
            $result_class = $helper->{app}
                        . "::"
                        . "Model::DB::"
                        . $source; 

            ### Declare config vars
            my @create_requires;
            my @create_allows;
            my @update_allows;
            my @list_search_exposes = my @list_returns = $schema->source($source)->columns;
            my @list_prefetch_allows = $schema->source($source)->relationships;
            my @list_ordered_by = $schema->source($source)->primary_columns;

            ### Prepare hash of column info for this class, so we can extract config
            my %source_col_info = map { $_, $schema->source($source)->column_info($_) } $schema->source($source)->columns;
            for my $k (sort keys %source_col_info) {
                if ( (  !$source_col_info{$k}->{'is_auto_increment'} ) && !( $source_col_info{$k}->{'default_value'} =~ /(nextval|sequence|timestamp)/ ) ) {
                    
                    ### Extract create required    
                    push @create_requires, $k if !$source_col_info{$k}->{'is_nullable'};

                    ### Extract create_allowed
                    push @create_allows, $k if $source_col_info{$k}->{'is_nullable'};
                }
                @update_allows = (@create_requires, @create_allows);
            }

            $helper->{class} = $class;
            $helper->{result_class} = $source;
            $helper->{class_name} = $schema->source_registrations->{$source}->name;
            $helper->{file} = $file;
            $helper->{create_requires} = join(' ', @create_requires);
            $helper->{create_allows} = join(' ', @create_allows);
            $helper->{list_returns} = join(' ', @list_returns);
            $helper->{list_search_exposes} = join(' ', @list_search_exposes);
            $helper->{update_allows} = join(' ', @update_allows);
            $helper->{list_prefetch_allows} = join(' ', @list_prefetch_allows);
            $helper->{list_ordered_by} = join(' ', @list_ordered_by);
            $helper->render_file( 'compclass', $file );
        }
}

1;

=head1 NAME

Catalyst::Helper::Controller::DBIC::API::REST

=head1 SYNOPSIS

    $ catalyst.pl myapp
    $ cd myapp
    $ script/myapp_create.pl controller API::REST DBIC::API::REST myapp

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
__apibase__
package [% app %]::Controller::API;

use strict;
use warnings;
use parent 'Catalyst::Controller';

sub api_base : Chained('/') PathPart('api') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

1;

__restbase__
package [% app %]::Controller::API::REST;

use strict;
use warnings;

use parent 'Catalyst::Controller::DBIC::API::REST';

sub rest_base : Chained('/api/api_base') PathPart('rest') CaptureArgs(0) {
    my ($self, $c) = @_;
}

1;
__compclass__
package [% class %];

use base 'Catalyst::Controller::DBIC::API::REST';

__PACKAGE__->config(
    action => { setup => { PathPart => '[% class_name  %]', Chained => '/api/rest/rest_base' } }, # define parent chain action and partpath
    class => '[% result_class %]', # DBIC result class
    create_requires => [qw/[% create_requires %]/], # columns required to create
    create_allows => [qw/[% create_allows %]/], # additional non-required columns that create allows
    update_allows => [qw/[% update_allows %]/], # columns that update allows
    list_returns => [qw/[% list_returns %]/], # columns that list returns
    list_prefetch => [qw/[% list_prefetch  %]/], # relationships that are prefetched when no prefetch param is passed
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

