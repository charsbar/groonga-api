use strict;
use warnings;
use Groonga::API::Test;

ctx_test(sub {
  my $ctx = shift;

  my $bulk = Groonga::API::obj_open($ctx, GRN_BULK, 0, GRN_DB_TEXT);
  ok defined $bulk, "created a bulk";
  is ref $bulk => "Groonga::API::obj", "correct object";

  {
    my $str = "text";
    my $rc = Groonga::API::bulk_write($ctx, $bulk, $str, bytes::length($str));
    is $rc => GRN_SUCCESS, "written";
    is $bulk->ub->{head} => $str, "written correctly";
  }

  {
    my $rc = Groonga::API::bulk_resize($ctx, $bulk, 10);
    is $rc => GRN_SUCCESS, "resized";
    note explain $bulk->ub;
  }

  {
    my $rc = Groonga::API::bulk_reinit($ctx, $bulk, 12);
    is $rc => GRN_SUCCESS, "reinitialized";
    note explain $bulk->ub;
  }

  {
    my $rc = Groonga::API::bulk_reserve($ctx, $bulk, 10);
    is $rc => GRN_SUCCESS, "reserved";
    note explain $bulk->ub;
  }

  {
    my $rc = Groonga::API::bulk_space($ctx, $bulk, 3);
    is $rc => GRN_SUCCESS, "spaced";
    note explain $bulk->ub;
  }

  {
    my $rc = Groonga::API::bulk_truncate($ctx, $bulk, 2);
    is $rc => GRN_SUCCESS, "truncated";
    note explain $bulk->ub;
  }

  {
    my $str = "new_text";
    my $rc = Groonga::API::bulk_write_from($ctx, $bulk, $str, 2, bytes::length($str));
    is $rc => GRN_SUCCESS, "written";
    is $bulk->ub->{head} => "tenew_text", "written correctly";
    note explain $bulk->ub;
  }

  Groonga::API::bulk_fin($ctx, $bulk);
  Groonga::API::obj_unlink($ctx, $bulk);
});

done_testing;
