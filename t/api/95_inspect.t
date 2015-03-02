use strict;
use warnings;
use Groonga::API::Test;

plan skip_all => 'requires 4.0.8' unless version_ge('4.0.8');

db_test(sub {
    my $ctx = shift;
    {
        ok Groonga::API::TEXT_INIT(my $buf, GRN_DB_TEXT);
        Groonga::API::inspect_encoding($ctx, $buf, GRN_ENC_DEFAULT);
        like substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf)) => qr/default\(.+?\)/;
        Groonga::API::obj_unlink($ctx, $buf);
    }

    {
        ok Groonga::API::TEXT_INIT(my $buf, GRN_DB_TEXT);
        Groonga::API::inspect_type($ctx, $buf, GRN_BULK);
        is substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf)) => 'GRN_BULK';
        Groonga::API::obj_unlink($ctx, $buf);
    }

    {
        ok Groonga::API::TEXT_INIT(my $buf, GRN_DB_TEXT);
        ok my $obj = Groonga::API::table_create($ctx, "table1", bytes::length("table1"), undef, GRN_OBJ_PERSISTENT, Groonga::API::ctx_at($ctx, GRN_DB_SHORT_TEXT), undef);
        Groonga::API::inspect_name($ctx, $buf, $obj);
        is substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf)) => 'table1';
        Groonga::API::obj_unlink($ctx, $buf);
        Groonga::API::obj_unlink($ctx, $obj);
    }

    {
        ok Groonga::API::TEXT_INIT(my $buf, GRN_DB_TEXT);
        ok my $obj = Groonga::API::table_create($ctx, "table2", bytes::length("table2"), undef, GRN_OBJ_PERSISTENT, Groonga::API::ctx_at($ctx, GRN_DB_SHORT_TEXT), undef);
        Groonga::API::inspect($ctx, $buf, $obj);
        like substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf)) => qr/^#<table:hash table2 key:ShortText value:\(nil\)/;
        note substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf));
        Groonga::API::obj_unlink($ctx, $buf);
        Groonga::API::obj_unlink($ctx, $obj);
    }

    {
        ok Groonga::API::TEXT_INIT(my $buf, GRN_DB_TEXT);
        ok my $obj = Groonga::API::table_create($ctx, "table3", bytes::length("table3"), undef, GRN_OBJ_PERSISTENT, Groonga::API::ctx_at($ctx, GRN_DB_SHORT_TEXT), undef);
        Groonga::API::inspect_indented($ctx, $buf, $obj, "   ");
        like substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf)) => qr/^#<table:hash table3 key:ShortText value:\(nil\)/;
        note substr(Groonga::API::TEXT_VALUE($buf), 0, Groonga::API::TEXT_LEN($buf));
        Groonga::API::obj_unlink($ctx, $buf);
        Groonga::API::obj_unlink($ctx, $obj);
    }

    {
        ok my $obj = Groonga::API::table_create($ctx, "table4", bytes::length("table4"), undef, GRN_OBJ_PERSISTENT, Groonga::API::ctx_at($ctx, GRN_DB_SHORT_TEXT), undef);
        Groonga::API::p($ctx, $obj);
        Groonga::API::obj_unlink($ctx, $obj);
    }
});

done_testing;
