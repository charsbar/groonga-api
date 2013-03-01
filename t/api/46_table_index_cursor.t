use strict;
use warnings;
use Groonga::API::Test;

indexed_table_test(sub {
  my ($ctx, $db, $table, $column, $index_table, $index_column) = @_;

  {
    my $rc = load_into_table($ctx, [
      {_key => 'key1', text => 'foo bar baz'},
      {_key => 'key2', text => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'},
      {_key => 'key3', text => 'Et tu, brute'},
    ]);
    is $rc => GRN_SUCCESS, "loaded";
  }

  my $t_cursor = Groonga::API::table_cursor_open($ctx, $index_table, undef, 0, undef, 0, 0, 100, GRN_CURSOR_ASCENDING);
  ok defined $t_cursor, "table cursor";
  is ref $t_cursor => "Groonga::API::table_cursor", "correct object";

  my $i_cursor = Groonga::API::index_cursor_open($ctx, $t_cursor, $index_column, 1, 100, GRN_CURSOR_ASCENDING);
  ok defined $i_cursor, "index cursor";
  is ref $i_cursor => "Groonga::API::obj", "correct object";

  my $id = 0;
  while(my $posting = Groonga::API::index_cursor_next($ctx, $i_cursor, $id)) {
    my $buf = ' ' x 4096;
    my $len = Groonga::API::table_get_key($ctx, $index_table, $id, $buf, bytes::length($buf));
    my $key = substr($buf, 0, $len);
    ok defined $key, "$id: $key";
  }

  Groonga::API::obj_close($ctx, $i_cursor);
  Groonga::API::table_cursor_close($ctx, $t_cursor);
});

done_testing;
