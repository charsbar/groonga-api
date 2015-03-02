use strict;
use warnings;
use Groonga::API::Test;

# adapted from groonga/test/unit/core/test-inverted-index.c

db_test(sub {
    my ($ctx, $db) = @_;
    ok my $users = Groonga::API::table_create($ctx, "users", bytes::length("users"), undef, GRN_OBJ_TABLE_NO_KEY|GRN_OBJ_PERSISTENT, undef, undef);
    ok my $items = Groonga::API::table_create($ctx, "items", bytes::length("items"), undef, GRN_OBJ_TABLE_PAT_KEY|GRN_OBJ_PERSISTENT, Groonga::API::ctx_at($ctx, GRN_DB_INT32), undef);
    ok my $checks = Groonga::API::column_create($ctx, $users, "checks", bytes::length("checks"), undef, GRN_OBJ_COLUMN_SCALAR|GRN_OBJ_PERSISTENT, $items);
    ok my $checked = Groonga::API::column_create($ctx, $items, "checked", bytes::length("checked"), undef, GRN_OBJ_COLUMN_INDEX|GRN_OBJ_PERSISTENT, $users);

    my $id = pack 'L', Groonga::API::obj_id($ctx, $checks);
    Groonga::API::TEXT_INIT(my $buf, 0);
    Groonga::API::bulk_write($ctx, $buf, $id, bytes::length($id));
    Groonga::API::obj_set_info($ctx, $checked, GRN_INFO_SOURCE, $buf);
    Groonga::API::obj_close($ctx, $buf);

    my $key = pack('L', 1);
    ok my $user1 = Groonga::API::table_add($ctx, $users, undef, 0, undef);
    ok my $user2 = Groonga::API::table_add($ctx, $users, undef, 0, undef);
    ok my $item = Groonga::API::table_add($ctx, $items, $key, bytes::length($key), undef);
    Groonga::API::TEXT_INIT(my $value, 0);
    Groonga::API::TEXT_INIT(my $query, 0);

    ok my $res = Groonga::API::table_create($ctx, undef, 0, undef, GRN_TABLE_HASH_KEY, $users, undef);
    my $item_p = pack 'L', $item;
    Groonga::API::bulk_write($ctx, $value, $item_p, bytes::length($item_p));
    $value->header({domain => Groonga::API::obj_id($ctx, $items)});
    Groonga::API::bulk_write($ctx, $query, $key, bytes::length($key));
    $query->header({domain => GRN_DB_INT32});

    Groonga::API::obj_set_value($ctx, $checks, $user1, $value, GRN_OBJ_SET);
    Groonga::API::obj_search($ctx, $checked, $value, $res, GRN_OP_OR, undef);
    inspect_obj($ctx, $res);
    is Groonga::API::table_size($ctx, $res) => 1;

    Groonga::API::obj_set_value($ctx, $checks, $user2, $value, GRN_OBJ_SET);
    Groonga::API::obj_search($ctx, $checked, $query, $res, GRN_OP_OR, undef);
    is Groonga::API::table_size($ctx, $res) => 2;

    Groonga::API::obj_close($ctx, $query);
    Groonga::API::obj_close($ctx, $value);
    Groonga::API::obj_close($ctx, $res);

    Groonga::API::obj_close($ctx, $checks);
    Groonga::API::obj_close($ctx, $checked);
    Groonga::API::obj_close($ctx, $items);
    Groonga::API::obj_close($ctx, $users);
});

done_testing;
