package # hide from PAUSE 
    RestTest::Schema::ResultSet::Track;

use base 'RestTest::Schema::ResultSet';

sub search {
	my $self = shift;
	my ($clause, $params) = @_;

	# test custom attrs
	if (my $pretend = delete $clause->{pretend}) {
		$clause->{'cd.year'} = $pretend;
	}
  my $rs = $self->SUPER::search(@_);	
}

1;
