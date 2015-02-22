use strict;
use warnings;
use Groonga::API::Test;

db_test(sub {
  my ($ctx, $db) = @_;

  my $version = Groonga::API::ctx_get_command_version($ctx);
  ok defined $version, "ctx command version: $version";

  my $rc = Groonga::API::ctx_set_command_version($ctx, $version);
  is $rc => GRN_SUCCESS, "set command version";
});

db_test(sub {
  my ($ctx, $db) = @_;

  my $threshold = Groonga::API::ctx_get_match_escalation_threshold($ctx);
  ok defined $threshold, "ctx match escalation threshold: $threshold";

  my $rc = Groonga::API::ctx_set_match_escalation_threshold($ctx, $threshold);
  is $rc => GRN_SUCCESS, "set match escalation threshold";
});

db_test(sub {
  my ($ctx, $db) = @_;

  my $rc = Groonga::API::ctx_info_get($ctx, my $info);
  is $rc => GRN_SUCCESS, "got ctx_info";
  note "COM STATUS: ".$info->com_status;
  note "STAT: ".$info->stat;
});

done_testing;
