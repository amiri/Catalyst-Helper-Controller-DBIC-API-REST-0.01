package # hide from PAUSE
    RestTest::Schema::Result::Tag;

use strict;
use warnings;

use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tags');
__PACKAGE__->add_columns(
  'tagid' => {
    data_type => 'integer',
    is_auto_increment => 1,
  },
  'cd' => {
    data_type => 'integer',
  },
  'tag' => {
    data_type => 'varchar',
    size      => 100,
  },
);
__PACKAGE__->set_primary_key('tagid');

__PACKAGE__->belongs_to( cd => 'RestTest::Schema::Result::CD' );

1;
