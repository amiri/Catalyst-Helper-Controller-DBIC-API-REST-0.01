package Catalyst::Helper::Controller::DBIC::API::REST;

use strict;
use FindBin;
use File::Spec;
use lib "$FindBin::Bin/../lib";

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

=head1 NAME

Catalyst::Helper::Controller::DBIC::API::REST

=head1 SYNOPSIS

    $ catalyst.pl myapp
    $ cd myapp
    $ script/myapp_create.pl controller API::REST DBIC::API::REST myapp

    ...

    package myapp::Controller::API::REST::Producer;

    use strict;
    use warnings;
    use base qw/myapp::ControllerBase::REST/;
    use JSON::Syck;

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

=head1 DESCRIPTION

  This creates REST controllers according to the specifications at L<Catalyst::Controller::DBIC::API> and L<Catalyst::Controller::DBIC::API::REST> for all the classes in your Catalyst app. Your application must access your model at myapp::Model::DB.

  It creates the following files:
    
    myapp/lib/myapp/Controller/API.pm
    myapp/lib/myapp/Controller/API/REST.pm
    myapp/lib/myapp/Controller/API/REST/*   (this is where the individual class controllers are located)
    myapp/lib/myapp/ControllerBase/REST.pm

=head2 CONFIGURATION

    The idea is to make configuration as painless and as automatic as possible, so most of the work has been done for you.
    
    There are 8 __PACKAGE__->config(...) options for L<Catalyst::Controller::DBIC::API/CONFIGURATION>. Here are the defaults.
    
=head2 create_requires

    All non-nullable columns that are (1) not autoincrementing, (2) don't have a default value, are neither (3) nextvals, (4) sequences, or (5) timestamps    

=head2 create_allows

    All nullable columns that are (1) not autoincrementing, (2) don't have a default value, are neither (3) nextvals, (4) sequences, or (5) timestamps.

=head2 update_allows

    The union of create_requires and create_allows.    

=head2 list_returns

    Every column in the class.

=head2 list_prefetch

    Nothing is prefetched by default.

=head2 list_prefetch_allows

    (1) An arrayref consisting of the name of each of the class's has_many relationships, accompanied by (2) a hashref keyed on the name of that relationship, whose values are the names of its has_many's, e.g., in the "Producer" controller above, a Producer has many cd_to_producers, many tags, and many tracks. None of those classes have any has_many's:

    list_prefetch_allows    =>  [
        [qw/cd_to_producer/], {  'cd_to_producer' => [qw//] },
        [qw/tags/], {  'tags' => [qw//] },
        [qw/tracks/], {  'tracks' => [qw//] },
    ],

=head2 list_ordered_by

    The primary key.

=head2 list_search_exposes
    
    (1) An arrayref consisting of the name of each column in the class, and (2) a hashref keyed on the name of each of the class's has many relationships, the values of which are all the columns in the corresponding class, e.g., 

    list_search_exposes     => [
        qw/cdid artist title year/,
        { 'cd_to_producer' => [qw/cd producer/] },
        { 'tags' => [qw/tagid cd tag/] },
        { 'tracks' => [qw/trackid cd position title last_updated_on/] },
    ], # columns that can be searched on via list

=head1 CONTROLLERBASE

    Following the advice in L<Catalyst::Controller::DBIC::API/EXTENDING>, this module creates an intermediate class between your controllers and L<Catalyst::Controller::DBIC::API::REST>. It contains one method, create, which serializes object information and stores it in the stash, which is not the default behavior.

=head1 METHODS

=head2 mk_compclass

This is the meat of the helper. It writes the directory structure if it is not in place, API.pm, REST.pm, the controllerbase, and the result class controllers. It replaces $helper->{} values as it goes through, rendering the files for each.

=back

=head1 AUTHOR

Amiri Barksdale E<lt>amiri@metalabel.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

sub mk_compclass {
    my ( $self, $helper, $schema_class ) = @_;
    $helper->{schema_class} = $schema_class;

    $helper->{script} = File::Spec->catdir( $helper->{dir}, 'script' ); 
    $helper->{appprefix} = Catalyst::Utils::appprefix($helper->{name});
        ## Connect to schema for class info
        my $schema_file = "$schema_class\/Schema";
        require "$schema_file.pm";
        my $schema_name = "$schema_class\:\:Schema";
        my $schema = $schema_name->connect;

        ## Lookup table for source lookups in list_prefetch_allows
        my %name_to_source = map { $schema->source($_)->name => $_ } $schema->sources;
        
        ## Make api base
        my $api_file = "$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/"
                        . $helper->{type}
                        . "/API.pm";
        (my $api_path = $api_file) =~ s/\.pm$//;
        $helper->mk_dir($api_path);
        $helper->render_file('apibase', $api_file);
        $helper->{test} = $helper->next_test('API');
        $helper->_mk_comptest;

        ## Make rest base
        my $rest_file = "$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/"
                        . $helper->{type}
                        . "/API/REST.pm";
        (my $rest_path = $rest_file) =~ s/\.pm$//;
        $helper->mk_dir($rest_path);
        $helper->render_file('restbase', $rest_file);
        $helper->{test} = $helper->next_test('API_REST');
        $helper->_mk_comptest;
    
        ## Make controller base
        my $base_file = "$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/ControllerBase"
                        . "/REST.pm";
        $helper->mk_dir("$FindBin::Bin/../lib/"
                        . $helper->{app}
                        . "/ControllerBase" );
        $helper->render_file('controllerbase', $base_file);
        $helper->{test} = $helper->next_test('controller_base');
        $helper->_mk_comptest;
        
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
                        . "::Model::DB::"
                        . $source; 

            ### Declare config vars
            my @create_requires;
            my @create_allows;
            my @update_allows;
            my @list_prefetch;
            my @list_search_exposes = my @list_returns = $schema->source($source)->columns;
            
            ### HAIRY RELATIONSHIPS STUFF
            my @sub_list_search_exposes = my @list_prefetch_allows = _return_has_many_list($schema->source($source)->_relationships);
            @list_prefetch_allows = map {
                my $ref = $_;
                qq|[qw/$ref->[0]/], { |
                . qq| '$ref->[0]' => [qw/|
                . join (' ', map { $_->[0] } _return_has_many_list($schema->source($ref->[1])->_relationships))
                . qq|/] },\n\t\t|;
            } @list_prefetch_allows;

            @sub_list_search_exposes = map {
                my $ref = $_;
                qq|{ '$ref->[0]' => [qw/|
                . join ( ' ', $schema->source($ref->[1])->columns )
                . qq|/] },\n\t\t|;
            } @sub_list_search_exposes;
            ### END HAIRY RELATIONSHIP STUFF
            
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
            $helper->{sub_list_search_exposes} = join('', @sub_list_search_exposes);
            $helper->{update_allows} = join(' ', @update_allows);
            $helper->{list_prefetch_allows} = join('', @list_prefetch_allows) if scalar @list_prefetch_allows > 0;
            $helper->{list_prefetch} = join(', ', map { qq|'$_->[0]'|  } @list_prefetch) if scalar @list_prefetch > 0; 
            $helper->{list_ordered_by} = join(' ', @list_ordered_by);
            $helper->render_file( 'compclass', $file );
            $helper->{test} = $helper->next_test($source);
            $helper->_mk_comptest;
        }
}

sub _return_has_many_list {
    my ($relationships) = @_;
    return grep { $relationships->{$_->[0]}->{attrs}->{accessor} =~ /multi/ } map { [$_, $relationships->{$_}->{source} ] } sort keys %$relationships;
}

1;

__DATA__
__apibase__
package [% app %]::Controller::API;

use strict;
use warnings;
use base qw/Catalyst::Controller/;

sub api_base : Chained('/') PathPart('api') CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

1;

__restbase__
package [% app %]::Controller::API::REST;

use strict;
use warnings;

use base qw/Catalyst::Controller/;

sub rest_base : Chained('/api/api_base') PathPart('rest') CaptureArgs(0) {
    my ($self, $c) = @_;
}

1;
__controllerbase__
package [% app %]::ControllerBase::REST;

use strict;
use warnings;
use base qw/Catalyst::Controller::DBIC::API::REST/;

sub create :Private {
my ($self, $c) = @_;
$self->next::method($c);
    if ($c->stash->{created_object}) {    
        %{$c->stash->{response}->{new_object}} = $c->stash->{created_object}->get_columns;
    }
}

1;
__compclass__
package [% class %];

use strict;
use warnings;
use base qw/[% app %]::ControllerBase::REST/;
use JSON::Syck;

__PACKAGE__->config(
    action                  =>  { setup => { PathPart => '[% class_name  %]', Chained => '/api/rest/rest_base' } },
                                # define parent chain action and partpath
    class                   =>  'DB::[% result_class %]', # DBIC result class
    create_requires         =>  [qw/[% create_requires %]/], # columns required to create
    create_allows           =>  [qw/[% create_allows %]/], # additional non-required columns that create allows
    update_allows           =>  [qw/[% update_allows %]/], # columns that update allows
    list_returns            =>  [qw/[% list_returns %]/], # columns that list returns
[% IF list_prefetch %]
    list_prefetch           =>  [[% list_prefetch %]], # relationships prefetched by default  
[% END %]
[% IF list_prefetch_allows %]
    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        [% list_prefetch_allows %]
    ],
[% END %]
    list_ordered_by         => [qw/[% list_ordered_by %]/], # order of generated list
    list_search_exposes     => [
        qw/[% list_search_exposes %]/,
        [% sub_list_search_exposes %]
    ], # columns that can be searched on via list
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
