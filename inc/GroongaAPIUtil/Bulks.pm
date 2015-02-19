package inc::GroongaAPIUtil::Bulks;

use strict;
use warnings;

my %value_type = (
  BOOL => 'unsigned char',
  INT8 => 'char',
  UINT8 => 'unsigned char',
  INT16 => 'short',
  UINT16 => 'unsigned short',
  INT32 => 'int',
  UINT32 => 'unsigned int',
  INT64 => 'long long int',
  UINT64 => 'long long unsigned int',
  FLOAT => 'double',
  TIME => 'long long int',
  RECORD => 'grn_id',
  PTR => 'grn_obj *',
  TEXT => 'char *',
  SHORT_TEXT => '',
  LONG_TEXT => '',
);

sub write {
  my $env = shift;

  write_inc($env->{dir}, extract($env));
}

sub extract {
  my $env = shift;
  my $h = $env->{h};

  my %data;

  my @to_export;

  $data{init} = [];
  my @init = $h =~ /#define GRN_([A-Z0-9_]+)_INIT\(/g;
  for (@init) {
    next unless exists $value_type{$_};
    push @to_export, $_."_INIT";
    push @{$data{init}}, $_;
  }

  $data{set} = [];
  my @set = $h =~ /#define GRN_([A-Z0-9_]+)_SET\(/g;
  for (@set) {
    next unless $value_type{$_};
    my $s = $_ eq "TEXT" ? "S" : "";
    push @to_export, $_."_SET$s";
    push @{$data{set}}, $_;
  }

  $data{set_at} = [];
  my @set_at = $h =~ /#define GRN_([A-Z0-9_]+)_SET_AT\(/g;
  for (@set_at) {
    next unless $value_type{$_};
    push @to_export, $_."_SET_AT";
    push @{$data{set_at}}, $_;
  }

  $data{value} = [];
  my @value = $h =~ /#define GRN_([A-Z0-9_]+)_VALUE\(/g;
  for (@value) {
    next unless $value_type{$_};
    push @to_export, $_."_VALUE";
    push @{$data{value}}, $_;
  }

  $data{value_at} = [];
  my @value_at = $h =~ /#define GRN_([A-Z0-9_]+)_VALUE_AT\(/g;
  for (@value_at) {
    next unless $value_type{$_};
    push @to_export, $_."_VALUE_AT";
    push @{$data{value_at}}, $_;
  }

  push @{$env->{to_export} ||= []}, @to_export;

  return \%data;
}

sub write_inc {
  my ($dir, $data) = @_;

  open my $out, '>', "$dir/bulk.inc" or die "Can't open bulk.inc: $!";
  for (@{$data->{init}}) {
    if ($_ eq 'PTR') {
      print $out <<"END";
SV *
${_}_INIT(grn_obj *obj, unsigned int flags, grn_id domain)
  CODE:
    GRN_${_}_INIT(obj, flags, domain);
    XSRETURN_YES;

END
    } else {
      print $out <<"END";
SV *
${_}_INIT(grn_obj *obj, unsigned int flags)
  CODE:
    GRN_${_}_INIT(obj, flags);
    XSRETURN_YES;

END
    }
  }

  for (@{$data->{set}}) {
    my $s = $_ eq "TEXT" ? "S" : "";
    print $out <<"END";
SV *
${_}_SET$s(grn_ctx *ctx, grn_obj *obj, $value_type{$_} value)
  CODE:
    GRN_${_}_SET$s(ctx, obj, value);
    XSRETURN_YES;

END
  }

  for (@{$data->{set_at}}) {
    print $out <<"END";
SV *
${_}_SET_AT(grn_ctx *ctx, grn_obj *obj, unsigned int offset, $value_type{$_} value)
  CODE:
    GRN_${_}_SET_AT(ctx, obj, offset, value);
    XSRETURN_YES;

END
  }

  for (@{$data->{value}}) {
    print $out <<"END";
$value_type{$_}
${_}_VALUE(grn_obj *obj)
  CODE:
    RETVAL = GRN_${_}_VALUE(obj);
  OUTPUT:
    RETVAL

END
  }

  for (@{$data->{value_at}}) {
    print $out <<"END";
$value_type{$_}
${_}_VALUE_AT(grn_obj *obj, unsigned int offset)
  CODE:
    RETVAL = GRN_${_}_VALUE_AT(obj, offset);
  OUTPUT:
    RETVAL

END
  }
}

1;
