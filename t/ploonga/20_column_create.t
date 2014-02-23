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
  ok defined $column, "created";
  is $column->name => "text", "correct name";

  $column->rename("new_text");

  my $renamed_column = $table->column("new_text");
  ok defined $renamed_column, "found";
});

done_testing;
