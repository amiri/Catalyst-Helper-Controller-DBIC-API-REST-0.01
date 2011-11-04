package # hide from PAUSE
    RestTest::Schema::Result::Artist;

use strict;
use warnings;

use base 'DBIx::Class::Core';

__PACKAGE__->table('artist');
__PACKAGE__->add_columns(
  'artistid' => {
    data_type => 'integer',
    is_auto_increment => 1,
  },
  'name' => {
    data_type => 'varchar',
    size      => 100,
    is_nullable => 0,
  },
);
__PACKAGE__->set_primary_key('artistid');

__PACKAGE__->has_many(
    cds => 'RestTest::Schema::Result::CD', undef,
    { order_by => 'year' },
);

1;
