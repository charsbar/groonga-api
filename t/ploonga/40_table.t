use strict;
use warnings;
use Groonga::API::Test;
use Ploonga::Database;

grn_test(sub {
  my $dbfile = tmpfile("test.db");
  my $db = Ploonga::Database->new(path => $dbfile);
  my $table = $db->create_table(
    name => "table",
    flags => GRN_OBJ_PERSISTENT|GRN_OBJ_TABLE_HASH_KEY,
    key_type => GRN_DB_SHORT_TEXT,
  );
  my $column = $table->create_column(
    name => "text",
    flags => GRN_OBJ_PERSISTENT,
    type => GRN_DB_SHORT_TEXT,
  );
  $db->load(table => "table", values => [
    {_key => "key1", text => "text1"},
    {_key => "key2", text => "text2"},
    {_key => "key3", text => "text3"},
  ]);

  my $size = $table->size;
  is $size => 3, "table size: $size";

  $table->add("key4", text => "text4");

note  $table->{ctx}->do("select --table table");

  $table->delete("key4");
note  $table->{ctx}->do("select --table table");
});

done_testing;
