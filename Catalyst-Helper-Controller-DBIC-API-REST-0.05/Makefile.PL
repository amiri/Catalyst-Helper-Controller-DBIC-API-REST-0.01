use inc::Module::Install;

name 'Catalyst-Helper-Controller-DBIC-API-REST';
all_from 'lib/Catalyst/Helper/Controller/DBIC/API/REST.pm';

requires 'Catalyst::Controller::DBIC::API';
requires 'Catalyst::Controller::DBIC::API::REST';
requires 'Module::Load';
requires 'parent';
requires 'Catalyst::Helper';

tests "t/*.pl";

if (Module::Install::AUTHOR) {
    system('pod2text lib/Catalyst/Helper/Controller/DBIC/API/REST.pm > README');
}

build_requires 'Test::More';
use_test_base;
auto_include;
auto_install;
WriteAll;
