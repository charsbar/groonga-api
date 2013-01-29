use strict;
use warnings;
use Groonga::API::Test;

ctx_test(sub {
  my $ctx = shift;

  my $version = Groonga::API::ctx_get_command_version($ctx);
  ok defined $version, "ctx command version: $version";

  my $rc = Groonga::API::ctx_set_command_version($ctx, $version);
  is $rc => GRN_SUCCESS, "set command version";
});

ctx_test(sub {
  my $ctx = shift;

  my $threshold = Groonga::API::ctx_get_match_escalation_threshold($ctx);
  ok defined $threshold, "ctx match escalation threshold: $threshold";

  my $rc = Groonga::API::ctx_set_match_escalation_threshold($ctx, $threshold);
  is $rc => GRN_SUCCESS, "set match escalation threshold";
});

done_testing;
