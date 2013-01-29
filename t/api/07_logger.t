use strict;
use warnings;
use Groonga::API::Test;

ctx_test(sub {
  my $ctx = shift;

  my $default_level = Groonga::API::default_logger_get_max_level();
  note "default logger level: $default_level";

  my $rc = Groonga::API::logger_pass($ctx, GRN_LOG_DUMP);
  ok $rc, "should log DUMP message";

  $rc = Groonga::API::logger_pass($ctx, GRN_LOG_ERROR);
  ok $rc, "should also log ERROR message";

  $rc = Groonga::API::logger_info_set($ctx, {
    max_level => GRN_LOG_NOTICE,
    flags => GRN_LOG_TIME|GRN_LOG_MESSAGE,
  });
  is $rc => GRN_SUCCESS, "set logger info";

  $rc = Groonga::API::logger_pass($ctx, GRN_LOG_DUMP);
  ok !$rc, "should not log DUMP message now";

  $rc = Groonga::API::logger_pass($ctx, GRN_LOG_ERROR);
  ok $rc, "should still log ERROR message";

  Groonga::API::logger_put($ctx, GRN_LOG_EMERG, __FILE__, __LINE__, 'test', '%s', "test");
});

# TODO: GRN_LOG() support?

done_testing;
