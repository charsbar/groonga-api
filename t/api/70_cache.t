use strict;
use warnings;
use Groonga::API qw/:all/;
use Groonga::API::Test;
use version;

plan skip_all => 'grn_cache was first introduced at 3.0.8' unless version->parse('v' . get_version()) >= version->parse('v3.0.8');

ctx_test(sub {
  my $ctx = shift;
  my $cache = cache_current_get($ctx);
  ok defined $cache, "got the cache";
  my $new_cache = cache_open($ctx);
  ok defined $new_cache, "opened a new cache";

  {
    my $max = cache_get_max_n_entries($ctx, $cache);
    ok $max, "got max_n_entries: $max";
    my $rc = cache_set_max_n_entries($ctx, $cache, $max + 1);
    is $rc => GRN_SUCCESS, "set max_n_entries";
  }
  {
    my $rc = cache_current_set($ctx, $new_cache);
    is $rc => GRN_SUCCESS, "set the new cache";
  }
  {
    my $rc = cache_close($ctx, $new_cache);
    is $rc => GRN_SUCCESS, "closed the new cache";
  }
});

done_testing;
