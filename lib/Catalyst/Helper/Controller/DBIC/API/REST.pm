package Catalyst::Helper::Controller::DBIC::API::REST;

use strict;
use FindBin;
use File::Spec;
use lib "$FindBin::Bin/../lib";
our $VERSION = '0.01';

=head1 NAME

Catalyst::Helper::Controller::DBIC::API::REST

=head1 VERSION

Version 0.01

=head1 SYNOPSIS

    $ catalyst.pl myapp
    $ cd myapp
    $ script/myapp_create.pl controller API::REST DBIC::API::REST myapp

=head1 DESCRIPTION

  This creates REST controllers for all the classes in your Catalyst app. Your application should access your model at myapp::Model::DB. If your result classes are not at that location, this will probably still work, but not optimally.

=cut

=over

=item mk_compclass

This is the meat of the helper. It writes the API.pm, REST.pm and result class controllers. It replaces $helper->{} values as it goes through, rendering the files for each.

=cut

sub mk_compclass {
    my ( $self, $helper, $schema_class ) = @_;
    $helper->{schema_class} = $schema_class;

#    print "Script and prefix: ", $helper->{script}, " ", $helper->{appprefix}, "\n";
#    print "Helper: ", Dumper $helper;
    $helper->{script} = File::Spec->catdir( $helper->{dir}, 'script' ); 
    $helper->{appprefix} = Catalyst::Utils::appprefix($helper->{name});
#    print "Script and prefix: ", $helper->{script}, " ", $helper->{appprefix}, "\n";
#    print "Helper: ", Dumper $helper;
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
            my @list_search_exposes = my @list_returns = $schema->source($source)->columns;
            
            ### HAIRY RELATIONSHIPS STUFF
            my @list_prefetch_allows = _return_has_many_list($schema->source($source)->_relationships);
            @list_prefetch_allows = map {
                my $ref = $_;
                qq|'$ref->[0]', { |
                . $ref->[0]
                . qq| => [qw/|
                . join (' ', map { $_->[0] } _return_has_many_list($schema->source($ref->[1])->_relationships))
                . qq|/] },\n\t\t|;
            } @list_prefetch_allows;
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
            $helper->{update_allows} = join(' ', @update_allows);
            $helper->{list_prefetch_allows} = join('', @list_prefetch_allows);
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

=back

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
    list_prefetch           =>  [qw/[% list_prefetch  %]/], # relationships that are prefetched
                                                            # when no prefetch param is passed
    list_prefetch_allows    =>  [ # every possible prefetch param allowed
        [% list_prefetch_allows %]
    ],
    list_ordered_by         => [qw/[% list_ordered_by %]/], # order of generated list
    list_search_exposes     => [qw/[% list_search_exposes %]/], # columns that can be searched on via list
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

