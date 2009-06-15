use inc::Module::Install;
name 'Catalyst-Helper-Controller-DBIC-API-REST';
all_from 'lib/Catalyst/Helper/Controller/DBIC/API/REST.pm';

requires 'Catalyst::Controller::DBIC::API';
requires 'Catalyst::Controller::DBIC::API::REST';
requires 'DBIx::Class::Schema';
requires 'Data::Dumper';


tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
auto_install;
WriteAll;
