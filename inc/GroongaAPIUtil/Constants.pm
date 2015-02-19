package inc::GroongaAPIUtil::Constants;

use strict;
use warnings;

sub write_files {
  my $env = shift;

  my $res = extract($env);

  write_pm($env->{dir}, $res);
  write_inc($env->{dir}, $res);
}

sub extract {
  my $env = shift;

  extract_typedefs($env);

  my $typedefs = extract_typedef_enums($env);
  my $defines  = extract_defines($env);

  my %tags = %$typedefs;
  for (keys %$defines) {
    warn "Tag $_ is duped\n" if $env->{author} && exists $tags{$_} && !/COMMAND_VERSION/;
    push @{$tags{$_} ||= []}, @{ $defines->{$_} };
  }
  my @constants = sort map {@{$tags{$_}}} keys %tags;
  my %seen_constants;
  for (@constants) {
    warn "Constant $_ is duped\n" if $env->{author} && $seen_constants{$_}++;
  }

  # custom tags
  $tags{BOOL} = [qw/GRN_TRUE GRN_FALSE/];
  $tags{OBJ_TYPES} = [qw/GRN_VOID GRN_BULK GRN_PTR GRN_UVECTOR GRN_PVECTOR GRN_VECTOR GRN_MSG GRN_QUERY GRN_ACCESSOR GRN_ACCESSOR_VIEW GRN_SNIP GRN_PATSNIP GRN_STRING GRN_CURSOR_TABLE_HASH_KEY GRN_CURSOR_TABLE_PAT_KEY GRN_CURSOR_TABLE_DAT_KEY GRN_CURSOR_TABLE_NO_KEY GRN_CURSOR_TABLE_VIEW GRN_CURSOR_COLUMN_INDEX GRN_CURSOR_COLUMN_GEO_INDEX GRN_TYPE GRN_PROC GRN_EXPR GRN_TABLE_HASH_KEY GRN_TABLE_PAT_KEY GRN_TABLE_DAT_KEY GRN_TABLE_NO_KEY GRN_TABLE_VIEW GRN_DB GRN_COLUMN_FIX_SIZE GRN_COLUMN_VAR_SIZE GRN_COLUMN_INDEX/];

  $tags{all} = \@constants;
  delete $tags{_};

  return {
    constants => \@constants,
    tags => \%tags,
  };
}

sub extract_typedefs {
  my $env = shift;
  my $h = $env->{h};

  my %seen;
  my %tags;
  my @typedefs = $h =~ /typedef\s+([a-z_ *]+)\s+([a-z_]+);/sg;
  for (my $i = 0; $i < @typedefs; $i += 2) {
    my ($type, $alias) = @typedefs[$i, $i + 1];
    next if $type =~ /^(struct|enum)/;
    $env->{typedef}{$alias} = $type;
  }
}

sub extract_typedef_enums {
  my $env = shift;
  my $h = $env->{h};

  my %seen;
  my %tags;
  my @typedefs = $h =~ /typedef\s+enum\s*\{(.+?)\}\s*(\w+);/sg;
  while(my ($def, $tag) = splice @typedefs, 0, 2) {
    $env->{typedef}{$tag} = 'T_ENUM';
    $tag =~ s/^grn_//;

    $def =~ s!/\*.+?\*/!!gs;
    $def =~ s!^#define .+!!mg;
    for (split /\s*,\s*/s, $def) {
      s/\s*=.+$//;
      s/^\s+//s;
      s/\s+$//s;
      next unless /^[A-Z0-9_]+$/;
      die "seen $_" if $seen{$_}++;
      push @{$tags{uc $tag} ||= []}, $_;
    }
  }

  return \%tags;
}

sub extract_defines {
  my $env = shift;
  my $h = $env->{h};

  my %ignore = map { $_ => 1 } qw/
    GRN_API GRN_INFO_CONFIGURE_OPTIONS GRN_INFO_CONFIG_PATH
    GRN_SNIP_MAPPING_HTML_ESCAPE GRN_NORMALIZER_AUTO
  /;

  my %seen;
  my %tags;
  my @defines_to_ignore = $h =~ /^#define\s+(GRN_[A-Z0-9_]+)\(/mg;
  for (@defines_to_ignore) {
    $ignore{$_} = 1;
  }

  my @defines_alias = $h =~ /^#define\s+(GRN_[A-Z0-9_]+\s+GRN_[A-Z0-9_]+)/mg;
  for (@defines_alias) {
    my ($def, $alias) = split /\s/;
    $ignore{$def} = 1 if $ignore{$alias};
  }

  my @defines = $h =~ /^#define\s+(GRN_[A-Z0-9_]+\b.*$)/mg;

  for (@defines) {
    my ($name, $value) = /^(GRN_[A-Z0-9_]+)\b(.*)$/;
    next if $ignore{$name};
    next if $value =~ /^\s*"/;
    die "seen $name" if $seen{$name}++;
    my ($tag) = $name =~ /^GRN_(ID|COMMAND_VERSION|QUERY_LOG|OBJ_FORMAT|OBJ|CURSOR|TABLE_GROUP|TABLE|COLUMN|QUERY|SNIP|LOG|STRING|STR|EXPR|CTX)_/;
    push @{$tags{$1 || '_'} ||= []}, $name;
  }

  return \%tags;
}

sub write_inc {
  my ($dir, $data) = @_;

  open my $out, '>', "$dir/constants.inc" or die "Can't open constants.inc: $!";
  my $alias = join "\n", map {"    $_ = $_"} @{$data->{constants}};
  print $out <<"END";
IV
grn_constant()
  ALIAS:
$alias
  CODE:
    RETVAL = ix;
  OUTPUT:
    RETVAL

END
}

sub write_pm {
  my ($dir, $data) = @_;

  open my $out, '>', "$dir/lib/Groonga/API/Constants.pm" or die "Can't open Constants.pm: $!";
  my $export_ok = join " ", @{$data->{constants}};
  my $export_tags = join ",\n  ",
    map {"$_ => [qw/" . join(" ", sort @{$data->{tags}{$_} || []}) ."/]"}
    sort keys %{$data->{tags}};

  print $out <<"END";
package Groonga::API::Constants;
use strict;
use warnings;
use base 'Exporter';
use Groonga::API;
our \@EXPORT_OK = qw($export_ok);
our \%EXPORT_TAGS = (
  $export_tags
);
1;

__END__

=head1 NAME

Groonga::API::Constants

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki\@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
END
}

1;
