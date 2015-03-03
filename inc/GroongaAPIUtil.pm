package inc::GroongaAPIUtil;

use strict;
use warnings;
use inc::GroongaAPIUtil::Constants;
use inc::GroongaAPIUtil::APIs;
use inc::GroongaAPIUtil::Bulks;
use inc::GroongaAPIUtil::Exports;

my $win32 = ($^O eq 'MSWin32');

sub write_files {
  my $env = shift;
  inc::GroongaAPIUtil::Constants::write_files($env);
  inc::GroongaAPIUtil::APIs::write_files($env);
  inc::GroongaAPIUtil::Bulks::write($env);
  inc::GroongaAPIUtil::Exports::write($env);
}

sub check_env {
  my ($groonga_h, $inc, $libs);

  my @incpath = qw(/usr/local/include/groonga /usr/include/groonga);
  if ($win32 && eval {require Win32}) {
    my $path = Win32::GetShortPathName('c:\Program Files\groonga\include\groonga');
    push @incpath, $path if $path;
  }
  if ($ENV{GROONGA_INC}) {
    $inc = $ENV{GROONGA_INC};
    $inc =~ s|^["']||;
    $inc =~ s|["']$||;
    $inc =~ s/^\-I//;
    $inc =~ s|\\|/|g;
    $inc =~ s|/$||g;
    unshift @incpath, $inc;
  }
  for (@incpath) {
    if (-e "$_/groonga.h") {
      $groonga_h = "$_/groonga.h";
      $inc = $_;
      last;
    }
  }
  unless ($groonga_h) {
    warn "groonga.h is not found; install groonga and/or set GROONGA_INC/GROONGA_LIBS environmental variables if necessary\n";
    return;
  }
  print "Found groonga.h: $groonga_h\n";

  my $h = slurp($groonga_h);

  (my $lib = $inc) =~ s|include([\\/]groonga)?$|lib|;
  $libs = $ENV{GROONGA_LIBS} || "-L$lib -l" . ($win32 ? "libgroonga.dll" : "groonga");
  $inc  = $ENV{GROONGA_INC}  || "-I$inc";

  print "INC: $inc\n";
  print "LIBS: $libs\n";

  return {
    author => (-d "$FindBin::Bin/.git"),
    groonga_h => $groonga_h,
    inc => $inc,
    libs => $libs,
    h => $h,
    dir => $FindBin::Bin,
  };
}

sub slurp {
  my $file = shift;
  my $h = _slurp($file);
  if (my @includes = $h =~ m!#include "(groonga/[^"]+)"!g) {
    (my $dir = $file) =~ s![\\/]groonga\.h$!!;
    for my $name (@includes) {
      my $sub_h = _slurp("$dir/$name");
      $h =~ s/#include "$name"/$sub_h\n/;
      # print "included $dir/$name\n";
    }
  }
  $h;
}

sub _slurp {
  my $file = shift;
  open my $fh, '<', $file or die "Can't open $file: $!";
  local $/;
  <$fh>;
}

1;
