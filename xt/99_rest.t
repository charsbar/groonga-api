use strict;
use warnings;
use Test::More;
use FindBin;

my $root = "$FindBin::Bin/../";

my %rest;
{
  open my $fh, '<', "$root/api.inc";
  while(<$fh>) {
    next if /^#/;
    my ($api) = $_ =~ /^grn_([a-z0-9_]+)\(/;
    $rest{$api} = 1 if $api;
  }
}

{
  for my $file (glob "$root/t/api/*.t") {
    next if $file =~ /rest\.t$/;
    my $test = do { open my $fh, '<', $file; local $/; <$fh> };
    my $pre = $test =~ m!Groonga::API\s+qw/:all/! ? qr/(?:Groonga::API::|\b)/ : qr/Groonga::API::/;
    for (keys %rest) {
      delete $rest{$_} if $test =~ /$pre$_\(|\&$pre$_\b/;
    }
  }
}

ok !%rest, "everything is tested";
diag explain [sort keys %rest];

done_testing;
