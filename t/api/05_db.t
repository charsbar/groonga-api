use strict;
use warnings;
use Groonga::API::Test;

ctx_test(sub {
  my $ctx = shift;

  my $dbfile = tmpfile("test.db");
  my $db = Groonga::API::db_create($ctx, $dbfile, undef);
  ok defined $db, "created another db";
  is ref $db => "Groonga::API::obj", "correct object";
  my $pt = $$db;
  ok $pt, "db pointer: $pt";

  Groonga::API::obj_close($ctx, $db);

  ok -f $dbfile, "dbfile exists";

  my $db_ = Groonga::API::db_open($ctx, $dbfile);
  ok defined $db_, "opened db";
  is ref $db_ => "Groonga::API::obj", "correct object";
  my $pt_ = $$db_;
  isnt $pt_ => $pt, "different pointer";

  my $db_c = Groonga::API::ctx_db($ctx);
  ok defined $db_c, "context db";
  is ref $db_c => "Groonga::API::obj", "correct object";
  my $pt_c = $$db_c;
  is $pt_c => $pt_, "correct pointer";

  my $db2 = Groonga::API::db_create($ctx, undef, undef);
  ok defined $db2, "created temp db";
  is ref $db2 => "Groonga::API::obj", "correct object";
  my $pt2 = $$db2;
  ok $pt2, "db pointer: $pt2";

  my $rc = Groonga::API::ctx_use($ctx, $db2);
  is $rc => GRN_SUCCESS, "use temp db";

  Groonga::API::obj_unlink($ctx, $db2) if $db2;
  Groonga::API::obj_unlink($ctx, $db_) if $db_;

  ok -f $dbfile, "dbfile still exists";
});

done_testing;
