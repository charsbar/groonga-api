use strict;
use warnings;
use FindBin;
use inc::GroongaAPIUtil;
use ExtUtils::MakeMaker::CPANfile;

my $env = inc::GroongaAPIUtil::check_env() or exit 0; # N/A
inc::GroongaAPIUtil::write_files($env);

my %params = (
  NAME          => 'Groonga::API',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/Groonga/API.pm',
  ABSTRACT_FROM => 'lib/Groonga/API.pm',
  LICENSE       => 'perl',
  OBJECT        => '$(O_FILES)',
  META_MERGE => {
    resources => {
      repository => 'https://github.com/charsbar/groonga-api',
    },
  },
  test => {TESTS => 't/*.t t/*/*.t'},
  clean => {FILES => '*.inc *.old *.log'},
);

for (qw/inc libs/) {
  $params{uc $_} = $env->{$_} if $env->{$_};
}

WriteMakefile(%params);
