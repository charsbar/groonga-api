use strict;
use warnings;
use Groonga::API::Test;
use Test::Fatal qw/lives_ok/;
use Ploonga::Context;

grn_test(sub {
  my $ctx = Ploonga::Context->new;
  ok $ctx, "created context";

  note "com_status: ".$ctx->info->com_status;
  note "stat: ".$ctx->info->stat;

  my $version = $ctx->command_version;
  ok defined $version, "command version: $version";
  lives_ok { $ctx->command_version($version) } "set command version";

  my $threshold = $ctx->match_escalation_threshold;
  ok defined $threshold, "match escalation threshold: $threshold";
  lives_ok { $ctx->match_escalation_threshold($threshold) } "set match escalation threshold";
});

done_testing;
