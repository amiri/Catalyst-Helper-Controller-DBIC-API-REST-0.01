use 5.6.0;

use strict;
use warnings;

use lib 't/lib';

my $base = 'http://localhost';
my $content_type = [ 'Content-Type', 'application/x-www-form-urlencoded' ];

use RestTest;
use DBICTest;
use Test::More tests => 11;
use Test::WWW::Mechanize::Catalyst 'RestTest';
use HTTP::Request::Common;
use JSON::Syck;

my $mech = Test::WWW::Mechanize::Catalyst->new;
ok(my $schema = DBICTest->init_schema(), 'got schema');

my $artist_create_url = "$base/api/rpc/artist/create";
my $any_artist_create_url = "$base/api/rpc/any/artist/create";
my $producer_create_url = "$base/api/rpc/producer/create";

# test validation when no params sent
{
  my $req = POST( $artist_create_url, {
	  wrong_param => 'value'
  }, 'Accept' => 'text/json' );
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 400, 'attempt without required params caught' );

  my $response = JSON::Syck::Load( $mech->content);
  is_deeply( $response->{messages}, ['No value supplied for name and no default'], 'correct message returned' );
}

# test default value used if default value exists
{
  my $req = POST( $producer_create_url, {

  }, 'Accept' => 'text/json' );
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'default value used when not supplied' );
  ok($schema->resultset('Producer')->find({ name => 'fred' }), 'record created with default name');
}

# test create works as expected when passing required value
{
  my $req = POST( $producer_create_url, {
	  name => 'king luke'
  }, 'Accept' => 'text/json' );
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'param value used when supplied' );

  my $new_obj = $schema->resultset('Producer')->find({ name => 'king luke' });
  ok($new_obj, 'record created with specified name');

  my $response = JSON::Syck::Load( $mech->content);
  is_deeply( $response->{new_producer}, { $new_obj->get_columns }, 'json for new producer returned' );
}

# test stash config handling
{
  my $req = POST( $any_artist_create_url, {
	  name => 'queen monkey'
  }, 'Accept' => 'text/json' );
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'stashed config okay' );

  my $new_obj = $schema->resultset('Artist')->find({ name => 'queen monkey' });
  ok($new_obj, 'record created with specified name');

  my $response = JSON::Syck::Load( $mech->content);
  is_deeply( $response, { success => 'true' }, 'json for new artist returned' );
}
