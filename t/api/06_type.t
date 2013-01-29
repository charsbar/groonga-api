use strict;
use warnings;
use Groonga::API::Test;

db_test(sub { # builtin type
  my ($ctx, $db) = @_;

  my $type = Groonga::API::ctx_at($ctx, GRN_DB_SHORT_TEXT);
  ok defined $type, "defined type";
  is ref $type => "Groonga::API::obj", "correct object";
  ok $$type, "type pointer: $$type";

  Groonga::API::obj_unlink($ctx, $type) if $type;
});

db_test(sub { # new type
  my ($ctx, $db) = @_;

  my $name = "NewType";
  my $type = Groonga::API::type_create($ctx, $name, bytes::length($name), GRN_OBJ_KEY_VAR_SIZE, 2147483647);
  ok defined $type, "defined type";
  is ref $type => "Groonga::API::obj", "correct object";
  ok $$type, "type pointer: $$type";

  Groonga::API::obj_unlink($ctx, $type) if $type;
});

done_testing;
