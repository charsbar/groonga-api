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
  ok defined $table, "created";
  lives_ok { $table->rename("new_table") } "renamed";

  my $renamed_table = $db->table("new_table");
  ok defined $renamed_table, "found correctly";
});

done_testing;
