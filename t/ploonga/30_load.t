use strict;
use warnings;
use Groonga::API::Test;
use Test::Fatal qw/lives_ok/;
use Ploonga::Database;

grn_test(sub {
  my $dbfile = tmpfile("test.db");
  my $db = Ploonga::Database->new(path => $dbfile);
  my $table = $db->create_table(
    name => "table",
    flags => GRN_OBJ_TABLE_HASH_KEY,
    key_type => GRN_DB_SHORT_TEXT,
  );
  my $column = $table->create_column(
    name => "text",
    flags => GRN_OBJ_PERSISTENT,
    type => GRN_DB_SHORT_TEXT,
  );
  lives_ok {
    $db->load(table => "table", values => [
      {_key => "key1", text => "text1"},
      {_key => "key2", text => "text2"},
      {_key => "key3", text => "text3"},
    ]);
  } "loaded";
});

done_testing;
