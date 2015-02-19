use strict;
use warnings;
use Test::More;
use FindBin;
use lib "$FindBin::Bin/../..";
use inc::GroongaAPIUtil;
use inc::GroongaAPIUtil::Bulks;

for my $dir (glob "$FindBin::Bin/include/*") {
  my ($version) = $dir =~ /([^\/]+)$/;
  ok my $h = inc::GroongaAPIUtil::slurp("$dir/groonga.h"), $version;
  ok my $res = eval { inc::GroongaAPIUtil::Bulks::extract({h => $h}) };
  # note explain $res;
}

done_testing;
