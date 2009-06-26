use strict;
use warnings;

use lib qw |t/lib|;
use lib qw |lib|;

my $base = 'http://localhost';

use RestTest;
use DBICTest;
use Test::More tests => 22;
use Test::WWW::Mechanize::Catalyst 'RestTest';
use HTTP::Request::Common;
use JSON::Syck;
use Catalyst::Helper;
use File::Copy::Recursive qw /dircopy/;
no warnings 'UNIVERSAL::isa';

my @files = qw[
    t/lib/RestTest/Controller/API.pm
    t/lib/RestTest/Controller/API/REST.pm
    t/lib/RestTest/ControllerBase/REST.pm
    t/lib/RestTest/Controller/API/REST/Artist.pm
    t/lib/RestTest/Controller/API/REST/CD.pm
    t/lib/RestTest/Controller/API/REST/Producer.pm
    t/lib/RestTest/Controller/API/REST/CD_to_Producer.pm
    t/lib/RestTest/Controller/API/REST/Tag.pm
    t/lib/RestTest/Controller/API/REST/Track.pm
    t/controller_API_REST.t
    t/controller_controller_base.t
    t/controller_API.t
    t/controller_Artist.t
    t/controller_CD.t
    t/controller_CD_to_Producer.t
    t/controller_Producer.t
    t/controller_Tag.t
    t/controller_Track.t
    ];

for my $file (@files) {
    unlink $file;
}

my $helper = Catalyst::Helper->new({ '.newfiles' => 1 });

ok($helper,'Helper creation');
diag("Helper created");

ok($helper->mk_component(   'RestTest', "controller", "API::REST", "DBIC::API::REST",
                            "RestTest",
                            ), "Controller file creation" );

ok(dircopy("lib/RestTest/Controller","t/lib/RestTest/Controller"), "Move files to proper location");
ok(dircopy("lib/RestTest/ControllerBase","t/lib/RestTest/ControllerBase"), "Move files to proper location");
for my $file (@files) {
ok(-e $file,"$file creation");
diag("Testing $file creation");
}

