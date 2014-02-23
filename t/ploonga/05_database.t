use strict;
use warnings;
use Groonga::API::Test;
use Ploonga::Database;
use Ploonga::Context;

grn_test(sub {
  my $dbfile = tmpfile("test.db");

  my $db = Ploonga::Database->new(path => $dbfile);
  ok defined $db, "created database";

  is $db->path => $dbfile, "correct path";
});

done_testing;
