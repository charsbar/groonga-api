use strict;
use warnings;
use Groonga::API::Test;

db_test(sub {
  my ($ctx, $db) = @_;
  my $command = "status";
  my $ret = Groonga::API::ctx_send($ctx, $command, bytes::length($command), 0);
  is $ret => GRN_SUCCESS, "send status";

  if (Groonga::API::get_default_command_version() > 1) {
    my $ctype = Groonga::API::ctx_get_mime_type($ctx);
    is $ctype => "application/json", "content type";
  }

  $ret = Groonga::API::ctx_recv($ctx, my $result, my $len, my $flags);  is $ret => GRN_SUCCESS, "received status";
  ok $result, "status: $result";
  ok $len, "result length: $len";
  note "flags: $flags";
});

# TODO: Groonga::API::ctx_connect() support

done_testing;
