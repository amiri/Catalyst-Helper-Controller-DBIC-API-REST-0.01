use 5.6.0;

use strict;
use warnings;

use lib 't/lib';

my $base = 'http://localhost';
my $content_type = [ 'Content-Type', 'application/x-www-form-urlencoded' ];

use RestTest;
use DBICTest;
use Test::More tests => 15;
use Test::WWW::Mechanize::Catalyst 'RestTest';
use HTTP::Request::Common;
use JSON::Syck;

my $mech = Test::WWW::Mechanize::Catalyst->new;
ok(my $schema = DBICTest->init_schema(), 'got schema');

my $track = $schema->resultset('Track')->first;
my %original_cols = $track->get_columns;

my $track_update_url = "$base/api/rest/track/" . $track->id;

# test invalid track id caught
{
	foreach my $wrong_id ('sdsdsdsd', 3434234) {
		my $incorrect_url = "$base/api/rest/track/" . $wrong_id;
		my $test_data = JSON::Syck::Dump({ title => 'value' });
		my $req = POST( $incorrect_url, Content => $test_data );
		$req->content_type('text/x-json');
		$mech->request($req);

		cmp_ok( $mech->status, '==', 400, 'Attempt with invalid track id caught' );
		
		my $response = JSON::Syck::Load( $mech->content);
		is_deeply( $response->{messages}, ['Invalid id'], 'correct message returned' );
		
		$track->discard_changes;
		is_deeply({ $track->get_columns }, \%original_cols, 'no update occurred');
	}
}

# validation when no params sent
{
	my $test_data = JSON::Syck::Dump({ wrong_param => 'value' });
	my $req = POST( $track_update_url, Content => $test_data );
	$req->content_type('text/x-json');
	$mech->request($req);

	cmp_ok( $mech->status, '==', 400, 'Update with no keys causes error' );

	my $response = JSON::Syck::Load( $mech->content);
	is_deeply( $response->{messages}, ['No valid keys passed'], 'correct message returned' );

	$track->discard_changes;
	is_deeply({ $track->get_columns }, \%original_cols, 'no update occurred');
}

{
	my $test_data = JSON::Syck::Dump({ title => undef });
	my $req = POST( $track_update_url, Content => $test_data );
	$req->content_type('text/x-json');
	$mech->request($req);
	cmp_ok( $mech->status, '==', 200, 'Update with key with no value okay' );

	$track->discard_changes;
	isnt($track->title, $original_cols{title}, 'Title changed');
	is($track->title, undef, 'Title changed to undef');
}

{
	my $test_data = JSON::Syck::Dump({ title => 'monkey monkey' });
	my $req = POST( $track_update_url, Content => $test_data );
	$req->content_type('text/x-json');
	$mech->request($req);

	cmp_ok( $mech->status, '==', 200, 'Update with key with value okay' );

	$track->discard_changes;
	is($track->title, 'monkey monkey', 'Title changed to "monkey monkey"');
}
