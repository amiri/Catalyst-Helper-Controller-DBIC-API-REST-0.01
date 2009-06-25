use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'RestTest' }
BEGIN { use_ok 'RestTest::Controller::API::REST::CD_to_Producer' }

ok( request('/api/rest')->is_success, 'Request should succeed' );

