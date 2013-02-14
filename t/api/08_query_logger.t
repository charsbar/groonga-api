use strict;
use warnings;
use Groonga::API::Test;

plan skip_all => 'requires groonga version > 1' if Groonga::API::get_major_version() == 1;

ctx_test(sub {
  my $ctx = shift;

  my $path = "./groonga_query.log";
  if (Groonga::API::get_major_version() > 2) {
    unlink $path if -f $path;
    Groonga::API::default_query_logger_set_path($path);
    is Groonga::API::default_query_logger_get_path() => $path, "correct path";
  }

  Groonga::API::default_query_logger_set_flags(GRN_QUERY_LOG_ALL);

  my $rc = Groonga::API::query_logger_pass($ctx, GRN_QUERY_LOG_CACHE);
  ok $rc, "should log CACHE";

  $rc = Groonga::API::query_logger_pass($ctx, GRN_QUERY_LOG_COMMAND);
  ok $rc, "should also log COMMAND";

  Groonga::API::default_query_logger_set_flags(GRN_QUERY_LOG_COMMAND);

  $rc = Groonga::API::query_logger_pass($ctx, GRN_QUERY_LOG_SIZE);
  ok !$rc, "should not log SIZE now";

  $rc = Groonga::API::query_logger_pass($ctx, GRN_QUERY_LOG_COMMAND);
  ok $rc, "should still log COMMAND";

  Groonga::API::query_logger_put($ctx, GRN_QUERY_LOG_COMMAND, __FILE__, __LINE__, 'test', '%s', "command");

  if (Groonga::API::get_major_version() > 2) {
    ok -s $path, "log file has been written";
    unlink $path if -f $path;
  }

  Groonga::API::query_logger_reopen($ctx);

  Groonga::API::query_logger_put($ctx, GRN_QUERY_LOG_COMMAND, __FILE__, __LINE__, 'test', '%s', "test");

  if (Groonga::API::get_major_version() > 2) {
    ok -s $path, "log file has been written";
    unlink $path if -f $path;
  }
});

# TODO: GRN_LOG() support?

done_testing;
