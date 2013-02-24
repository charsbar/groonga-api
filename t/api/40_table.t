use strict;
use warnings;
use Groonga::API::Test;

table_column_test(sub {
  my ($ctx, $db, $table, $column) = @_;

  my $rc = load_into_table($ctx, [
    {_key => 'key1', text => 'text1'},
    {_key => 'key2', text => 'text2'},
    {_key => 'key3', text => 'text3'},
  ]);
  is $rc => GRN_SUCCESS;

  {
    my $size = Groonga::API::table_size($ctx, $table);
    is $size => 3, "table size: $size";
  }

  {
    my $id = Groonga::API::table_at($ctx, $table, 1);
    is $id => 1, "record #1 exists";
  }

  {
    my $key = "key1";
    my $id = Groonga::API::table_get($ctx, $table, $key, bytes::length($key));
    is $id => 1, "got by key";
  }

  {
    my $buf = " " x 4096;
    my $len = Groonga::API::table_get_key($ctx, $table, 1, $buf, bytes::length($buf));
    my $key = $len ? substr($buf, 0, $len) : "";

    ok $len, "key1 length: $len";
    is $key => "key1", "key1: $key";
  }

  {
    my $name = "key1";
    my $new_id = Groonga::API::table_add($ctx, $table, $name, bytes::length($name), my $added);
    is $new_id => 1, "added an existing record";
    ok !$added, "added flag indicates false";
  }

  {
    my $name = "key4";
    my $new_id = Groonga::API::table_add($ctx, $table, $name, bytes::length($name), my $added);
    is $new_id => 4, "added a new record";
    ok $added, "added flag indicates true";
  }

  {
    my $name = "key4";
    my $id = Groonga::API::table_lcp_search($ctx, $table, $name, bytes::length($name));
    is $id => 4, "found the id";
  }

  {
    my $name = "key4";
    my $rc = Groonga::API::table_delete($ctx, $table, $name, bytes::length($name));
    is $rc => GRN_SUCCESS, "deleted a record";
  }

  {
    my $rc = Groonga::API::table_delete_by_id($ctx, $table, 3);
    is $rc => GRN_SUCCESS, "deleted a record by id";
  }

  {
    Groonga::API::obj_defrag($ctx, $table, 0);
    Groonga::API::obj_defrag($ctx, $db, 0);
  }

  {
    my $rc = Groonga::API::table_truncate($ctx, $table);
    is $rc => GRN_SUCCESS, "truncated";
  }
});

table_test(sub {
  my ($ctx, $db, $table, $column) = @_;

  my $rc = load_into_table($ctx, [
    {_key => 'key1', text => 'text1'},
    {_key => 'key2', text => 'text2'},
    {_key => 'key3', text => 'text3'},
  ]);
  is $rc => GRN_SUCCESS;

  {
    my $new_key = "new_key1";
    $rc = Groonga::API::table_update_by_id($ctx, $table, 1, $new_key, bytes::length($new_key));

    my $buf = " " x 4096;
    my $len = Groonga::API::table_get_key($ctx, $table, 1, $buf, bytes::length($buf));
    my $key = $len ? substr($buf, 0, $len) : "";

    ok $len, "new key1 length: $len";
    is $key => "new_key1", "new key1: $key";
  }

  {
    my $src_key = "key1";
    my $dest_key = "new_key1";
    $rc = Groonga::API::table_update($ctx, $table, $src_key, bytes::length($src_key), $dest_key, bytes::length($dest_key));

    my $buf = " " x 4096;
    my $len = Groonga::API::table_get_key($ctx, $table, 1, $buf, bytes::length($buf));
    my $key = $len ? substr($buf, 0, $len) : "";

    ok $len, "new key1 length: $len";
    is $key => $dest_key, "new key1: $key";
  }


}, table_key => GRN_OBJ_PERSISTENT|GRN_TABLE_DAT_KEY);

done_testing;
