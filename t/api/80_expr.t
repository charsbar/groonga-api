use strict;
use warnings;
use Groonga::API::Test;

# adapted from groonga/test/unit/core/test-expr.c

db_test(sub {
  my ($ctx, $db) = @_;

  ok my $table = Groonga::API::table_create($ctx, "table", bytes::length("table"), undef, GRN_OBJ_TABLE_NO_KEY|GRN_OBJ_PERSISTENT, undef, undef);

  ok my $column = Groonga::API::column_create($ctx, $table, "column", bytes::length("column"), undef, GRN_OBJ_PERSISTENT, $table);
  Groonga::API::RECORD_INIT(my $record, 0, Groonga::API::obj_id($ctx, $table));
  inspect_obj($ctx, $table);
  inspect_obj($ctx, $column);
  inspect_obj($ctx, $record);

  for (1..10) {
    my $id = Groonga::API::table_add($ctx, $table, undef, 0, undef);
    Groonga::API::RECORD_SET($ctx, $record, $id);
    Groonga::API::obj_set_value($ctx, $column, $id, $record, GRN_OBJ_SET);
  }

  Groonga::API::TEXT_INIT(my $buf, 0);
  ok my $expr = Groonga::API::expr_create($ctx, undef, 0);

  my $v = Groonga::API::expr_add_var($ctx, $expr, undef, 0);
  Groonga::API::RECORD_INIT($v, 0, Groonga::API::obj_id($ctx, $table));

  Groonga::API::expr_append_obj($ctx, $expr, $v, GRN_OP_PUSH, 1);

  Groonga::API::TEXT_SETS($ctx, $buf, "column");
  Groonga::API::expr_append_const($ctx, $expr, $buf, GRN_OP_PUSH, 1);
  Groonga::API::expr_append_op($ctx, $expr, GRN_OP_GET_VALUE, 2);
  inspect_obj($ctx, $expr);

  Groonga::API::expr_compile($ctx, $expr);

  ok my $cursor = Groonga::API::table_cursor_open($ctx, $table, undef, 0, undef, 0, 0, -1, 0);
  while(my $id = Groonga::API::table_cursor_next($ctx, $cursor)) {
    Groonga::API::RECORD_SET($ctx, $v, $id);
    my $r = Groonga::API::expr_exec($ctx, $expr, 0);
    is Groonga::API::RECORD_VALUE($r) => $id;
  }
  Groonga::API::table_cursor_close($ctx, $cursor);

  {
    my $rc = Groonga::API::expr_close($ctx, $expr);
    is $rc => GRN_SUCCESS;
  }

  Groonga::API::obj_unlink($ctx, $record);
  Groonga::API::obj_unlink($ctx, $buf);
  Groonga::API::obj_unlink($ctx, $column);
  Groonga::API::obj_unlink($ctx, $table);
});

done_testing;
