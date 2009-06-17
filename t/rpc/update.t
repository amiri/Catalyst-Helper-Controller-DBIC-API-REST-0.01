use 5.6.0;

use strict;
use warnings;

use lib 't/lib';

my $base = 'http://localhost';
my $content_type = [ 'Content-Type', 'application/x-www-form-urlencoded' ];

use RestTest;
use DBICTest;
use Test::More tests => 23;
use Test::WWW::Mechanize::Catalyst 'RestTest';
use HTTP::Request::Common;
use JSON::Syck;

my $mech = Test::WWW::Mechanize::Catalyst->new;
ok(my $schema = DBICTest->init_schema(), 'got schema');

my $track = $schema->resultset('Track')->first;
my %original_cols = $track->get_columns;

my $track_update_url = "$base/api/rpc/track/id/" . $track->id . "/update";
my $any_track_update_url = "$base/api/rpc/any/track/id/" . $track->id . "/update";

# test invalid track id caught
{
		foreach my $wrong_id ('sdsdsdsd', 3434234) {
			my $incorrect_url = "$base/api/rpc/track/id/" . $wrong_id . "/update";
			my $req = POST( $incorrect_url, {
			title => 'value'
		});

		$mech->request($req, $content_type);
		cmp_ok( $mech->status, '==', 400, 'Attempt with invalid track id caught' );
		
		my $response = JSON::Syck::Load( $mech->content);
		is_deeply( $response->{messages}, ['Invalid id'], 'correct message returned' );
		
		$track->discard_changes;
		is_deeply({ $track->get_columns }, \%original_cols, 'no update occurred');
	}
}

# validation when no params sent
{
  my $req = POST( $track_update_url, {
	  wrong_param => 'value'
  });
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 400, 'Update with no keys causes error' );

  my $response = JSON::Syck::Load( $mech->content);
  is_deeply( $response->{messages}, ['No valid keys passed'], 'correct message returned' );

  $track->discard_changes;
  is_deeply({ $track->get_columns }, \%original_cols, 'no update occurred');
}

{
  my $req = POST( $track_update_url, {
	  wrong_param => 'value'
  });
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 400, 'Update with no keys causes error' );

  my $response = JSON::Syck::Load( $mech->content);
  is_deeply( $response->{messages}, ['No valid keys passed'], 'correct message returned' );

  $track->discard_changes;
  is_deeply({ $track->get_columns }, \%original_cols, 'no update occurred');
}

{
  my $req = POST( $track_update_url, {
	  title => undef
  });
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'Update with key with no value okay' );

  $track->discard_changes;
  isnt($track->title, $original_cols{title}, 'Title changed');
  is($track->title, '', 'Title changed to undef');
}

{
  my $req = POST( $track_update_url, {
	  title => 'monkey monkey'
  });
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'Update with key with value okay' );

  $track->discard_changes;
  is($track->title, 'monkey monkey', 'Title changed to "monkey monkey"');
}

{
  my $req = POST( $track_update_url, {
	  title => 'sheep sheep',
	  'cd.year' => '2009'
  });
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'Update with key with value and related key okay' );

  $track->discard_changes;
  is($track->title, 'sheep sheep', 'Title changed');
  is($track->cd->year, '2009', 'Related field changed"');
}

{
  my $req = POST( $any_track_update_url, {
	  title => 'baa'
  });
  $mech->request($req, $content_type);
  cmp_ok( $mech->status, '==', 200, 'Stash update okay' );

  $track->discard_changes;
  is($track->title, 'baa', 'Title changed');
}
