package inc::GroongaAPIUtil::APIs;

use strict;
use warnings;

my %todo = map {("grn_$_" => 1)} qw/
  text_vprintf
  expr_add_var expr_get_var expr_get_var_by_offset expr_append_obj
  expr_append_const expr_append_const_str expr_exec expr_alloc
  expr_create expr_append_const_int inspect
  inspect_indented inspect_name inspect_encoding inspect_type
  proc_call_next proc_get_hook_local_data proc_get_ctx_local_data
/;

my %basic_types = ( # from ExtUtils::typemap
  'int' => 'T_IV',
  'unsigned' => 'T_UV',
  'unsigned int' => 'T_UV',
  'long' => 'T_IV',
  'unsigned long' => 'T_UV',
  'short' => 'T_IV',
  'unsigned short' => 'T_UV',
  'char' => 'T_CHAR',
  'unsigned char' => 'T_U_CHAR',
  'char *' => 'T_PV',
  'unsigned char *' => 'T_PV',
  'const char *' => 'T_PV',
  'caddr_t' => 'T_PV',
  'wchar_t *' => 'T_PV',
  'wchar_t' => 'T_IV',
  'bool_t' => 'T_IV',
  'size_t' => 'T_UV',
  'ssize_t' => 'T_IV',
  'time_t' => 'T_NV',
  'unsigned long *' => 'T_OPAQUEPTR',
  'char **' => 'T_PACKEDARRAY',
  'void *' => 'T_PTR',
  'Time_t *' => 'T_PV',
  'float' => 'T_FLOAT',
  'double' => 'T_DOUBLE',
  'bool' => 'T_BOOL',
);
my @typemap = (
  'grn_ctx *' => 'T_GRN_CTX',
  'grn_obj *' => 'T_GRN_OBJ',
  'grn_pat *' => 'T_GRN_OBJ',
  'grn_dat *' => 'T_GRN_OBJ',
  'grn_posting *' => 'T_GRN_OBJ',
  'grn_cache *' => 'T_GRN_OBJ',
  'grn_table_cursor *' => 'T_GRN_OBJ',
  'grn_array_cursor *' => 'T_GRN_OBJ',
  'grn_hash_cursor *' => 'T_GRN_OBJ',
  'grn_pat_cursor *' => 'T_GRN_OBJ',
  'grn_dat_cursor *' => 'T_GRN_OBJ',

  'grn_db_create_optarg *' => 'T_GRN_IGNORE',
  'grn_obj_flags' => 'T_U_SHORT',
  'grn_content_type' => 'T_ENUM',
  'grn_operator' => 'T_ENUM',
  'grn_array *' => 'T_GRN_OBJ',
  'grn_hash *' => 'T_GRN_OBJ',
  'const grn_logger_info *' => 'T_GRN_LOGGER_INFO',
  grn_id => 'T_U_INT',
  grn_bool => 'T_U_CHAR',
  grn_expr_flags => 'T_U_INT',
  'grn_table_delete_optarg *' => 'T_GRN_IGNORE',
  grn_info_type => 'T_ENUM',
  'grn_table_sort_key *' => 'T_GRN_TABLE_SORT_KEY',
  'grn_ctx_info *' => 'T_GRN_CTX_INFO',

  'long long int' => 'T_IV',
  'long long unsigned int' => 'T_UV',
  'unsigned short int' => 'T_UV',
  'const void *' => 'T_PV_OR_UNDEF',
  'const char *' => 'T_PV_OR_UNDEF',
  'const unsigned char *' => 'T_PV_OR_UNDEF',
  'char *' => 'T_PV_OR_UNDEF',
  'void *' => 'T_OPAQUE_',
  'const short *' => 'T_OPAQUE_',
  'short *' => 'T_OPAQUE_',
);

my %inout = (
  grn_table_add => {'int *added' => 'OUT int added_out'},
  grn_table_get_key => {'void *keybuf' => 'void *keybuf_pv'},
  grn_table_cursor_get_key => {'void **key' => 'OUT void *key_out_length_RETVAL'},
  grn_table_cursor_get_value => {'void **value' => 'OUT void *value_out_length_RETVAL'},
  grn_ctx_recv => {
    'char **str' => 'OUT char *str_out',
    'unsigned int *str_len', 'OUT unsigned int str_len_out',
    'int *flags', 'OUT int flags_out',
  },
  grn_hash_add => {
    'int *added' => 'OUT int added_out',
    'void **value' => 'OUT void *value_out',
  },
  grn_hash_get => {'void **value' => 'OUT void *value_out'},
  grn_hash_get_key => {'void *keybuf' => 'void *keybuf_pv'},
  grn_hash_get_value => {'void *valuebuf' => 'void *valuebuf_pv'},
  grn_hash_cursor_get_key => {'void **key' => 'OUT void *key_out_length_RETVAL'},
  grn_hash_cursor_get_value => {'void **value' => 'OUT void *value_out_length_RETVAL'},
  grn_hash_cursor_get_key_value => {
    'void **key' => 'OUT void *key_out',
    'unsigned int *key_size' => 'OUT unsigned int key_size_out',
    'void **value' => 'OUT void *value_out_length_RETVAL',
  },
  grn_array_add => {'void **value' => 'OUT void *value_out'},
  grn_array_get_value => {'void *valuebuf' => 'void *valuebuf_pv'},
  grn_array_cursor_get_value => {'void **value' => 'OUT void *value_out_length_RETVAL'},
  grn_dat_add => {
    'int *added' => 'OUT int added_out',
    'void **value' => 'NULL',
  },
  grn_dat_get => {'void **value' => 'NULL'},
  grn_dat_get_key => {'void *keybuf' => 'void *keybuf_pv'},
  grn_dat_cursor_get_key => {'const void **key' => 'OUT const void *key_out_length_RETVAL'},
  grn_pat_add => {
    'int *added' => 'OUT int added_out',
    'void **value' => 'OUT void *value_out',
  },
  grn_pat_get => {'void **value' => 'OUT void *value_out'},
  grn_pat_get_key => {'void *keybuf' => 'void *keybuf_pv'},
  grn_pat_get_value => {'void *valuebuf' => 'void *valuebuf_pv'},
  grn_pat_cursor_get_key => {'void **key' => 'OUT void *key_out_length_RETVAL'},
  grn_pat_cursor_get_value => {'void **value' => 'OUT void *value_out_length_RETVAL'},
  grn_pat_cursor_get_key_value => {
    'void **key' => 'OUT void *key_out',
    'unsigned int *key_size' => 'OUT unsigned int key_size_out',
    'void **value' => 'OUT void *value_out_length_RETVAL',
  },
  grn_table_sort_key_from_str => {'unsigned int *nkeys' => 'OUT unsigned int nkeys'},
  grn_index_cursor_next => {'grn_id *tid' => 'IN_OUT grn_id tid'},
  grn_string_get_original => {
    'const char **original' => 'OUT const char *original_out_length_length_in_bytes_out',
    'unsigned int *length_in_bytes' => 'OUT unsigned int length_in_bytes_out',
  },
  grn_string_get_normalized => {
    'const char **normalized' => 'OUT const char *normalized_out_length_length_in_bytes_out',
    'unsigned int *length_in_bytes' => 'OUT unsigned int length_in_bytes_out',
    'unsigned int *n_characters' => 'OUT unsigned int n_characters_out',
  },
  grn_table_get_subrecs => {
    'grn_id *subrecbuf' => 'OUT grn_id subrecbuf',
    'int *scorebuf' => 'OUT int scorebuf',
  },
  grn_text_vprintf => {'va_list args' => '...'},
  grn_logger_put => {'const char *fmt' => 'const char *format_with_va_list'},
  grn_query_logger_put => {'const char *format' => 'const char *format_with_va_list'},
);

sub write_files {
  my $env = shift;
  my $res = extract($env);
  write_inc($env->{dir}, $res);
  write_attrs($env->{dir}, $res);
  write_typemap($env->{dir}, $res);
}

sub extract {
  my $env = shift;
  my $h = $env->{h};

  my %types;

  my @api_strings = $h =~ /\nGRN_API ([^;]+;)/gs;
  printf "Found %d APIs\n", scalar @api_strings;

  my %known_types = (%basic_types, void => 1, @typemap);
  for (keys %{$env->{typedef} || {}}) {
    my $type = $env->{typedef}{$_};
    if ($type =~ /^T_/) {
      $known_types{$_} = $type;
      push @typemap, ($_ => $type);
    } elsif ($known_types{$type}) {
      $known_types{$_} = $known_types{$type};
    } elsif ($known_types{"$type *"}) {
    } else {
      warn "UNKNOWN TYPEDEF: $_\n" if $env->{author};
    }
  }

  my $supported = 0;
  my @to_export;
  my @apis;
  for (@api_strings) {
    s/\s\s+/ /gs;
    s/\(void\)/()/g;
    s/\s+[A-Z][A-Z_]+\([^)]+\);/;/;
    my ($type, $decl) = split / /, $_, 2;
    if ($decl =~ /^grn_/) {
    } elsif ($decl =~ s/^(.+?)(_?grn_)/$2/) {
      $type .= " $1";
    }
    $type =~ s/\s+$//;
    $decl =~ s/\s+[A-Z][A-Z_]+\([0-9]+\);$/;/;
    my ($name) = $decl =~ /^([^(]+)/;

    if ($inout{$name}) {
      if (ref $inout{$name}) {
        for (keys %{$inout{$name}}) {
          $decl =~ s/\Q$_\E/$inout{$name}{$_}/;
        }
      }
      else {
        $decl =~ s/\Q$inout{$name}\E/IN_OUT $inout{$name}_inout/;
      }
    }
    my ($args) = $decl =~ /^$name\((.+)\);/;
    $args = '' unless defined $args;

    my @reasons;
    if ($args =~ s/void\s*\(\*([^)]+)\)\(.+?\)/void *$1/g) {
      push @reasons, "has function $1";
      warn "HAS FUNC ($name): $1\n" if $env->{author};
    }
    my @unknown_types = grep {
      $_ ne '' &&
      $_ ne '...' &&
      $_ ne 'va_list' &&
      !$known_types{$_}
    } map {
      s/[a-zA-Z0-9_]+$//;
      s/(IN_)?OUT //;
      s/\s+$//;
      $_
    } split /,\s*/, $args;

    if (@unknown_types) {
      push @reasons, "unknown types: ".join ', ', @unknown_types;
      warn "UNKNOWN TYPES ($name): ".(join ', ', @unknown_types)."\n" if $env->{author};
    }
    if (!$known_types{$type}) {
      push @reasons, "unknown type: $type";
    }
    if ($todo{$name}) {
      push @reasons, "$name is marked as TODO";
    }

    if (@reasons) {
      push @apis, {todo => \@reasons, type => $type, decl => $decl};
    } else {
      $types{$type} = 1;
      push @apis, {type => $type, decl => $decl};
      (my $export_name = $name) =~ s/^grn_//;
      push @to_export, $export_name;
      $supported++;
    }
  }
  printf "Supported %d APIs\n", $supported;

  push @{$env->{to_export} ||= []}, @to_export;

  my @structs = $h =~ /struct\s+((?:\w+\s+)?{.+?}(?:\s+\w+)?);/gs;
  my %attrs;
  for my $struct (@structs) {
    $struct =~ /(\w+\s+)?{(.+?)}(\s+\w+)?/gs;
    my $name = $1 || $3;
    my $def = $2;
    ($name) = $name =~ /^\s*_?(\w+)\s*/;
    next unless $name =~ /^grn_/;
    unless ($known_types{"$name *"}) {
      warn "UNKNOWN TYPE: $name *\n";
      next;
    }
    my @defs =
      map {s/;\s*$//; s/(\w+)\[.+?\]$/*$1/; $_}
      grep {$_ ne '' && !/\(/}
      split /\n/, $def;
    for (@defs) {
      my ($type, $attr) = /^\s*(.+?)\s*(\w+)$/;
      next unless $type;
      unless ($known_types{$type}) {
        warn "UNKNOWN TYPE: $type ($name.$attr)";
        next;
      }
      $attrs{$name}{$attr} = $type;
    }
  }

  return {
    apis => \@apis,
    types => \%types,
    attrs => \%attrs,
  };
}

sub write_inc {
  my ($dir, $data) = @_;

  open my $out, '>', "$dir/api.inc" or die "Can't open api.inc: $!";
  for (@{$data->{apis}}) {
    if ($_->{todo}) {
      print $out "# $_\n" for @{$_->{todo}};
      print $out "# $_->{type}\n# $_->{decl}\n\n";
    } else {
      print $out "$_->{type}\n$_->{decl}\n\n";
    }
  }
}

sub write_attrs {
  my ($dir, $data) = @_;

  for my $type (keys %{$data->{attrs}}) {
    (my $name = $type) =~ s/^grn_//;
    my $attrs = $data->{attrs}{$type};
    open my $out, '>', "$dir/attr_$name.inc" or die "Can't open attr_$name.inc: $!";
    for (sort keys %$attrs) {
      print $out <<"END";
$attrs->{$_}
$_($type *$name)
  CODE:
    RETVAL = $name->$_;
  OUTPUT:
    RETVAL

END
    }
  }
}

sub write_typemap {
  my ($dir, $data) = @_;

  open my $out, '>', "$dir/typemap" or die "Can't open typemap: $!";
  print $out "TYPEMAP\n";
  for (my $i = 0; $i < @typemap; $i += 2) {
    my ($type, $xs_type) = @typemap[$i, $i+1];
    print $out $type, "\t", $xs_type, "\n";
  }
  print $out <<'TYPEMAP';

INPUT
T_GRN_CTX
  if (!SvOK($arg)) {
    Newx($var, 1, grn_ctx);
    sv_setref_pv($arg, \"Groonga::API::ctx\", (void*)$var);
  } else if (sv_derived_from($arg, \"${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\")){
    IV tmp = SvIV((SV*)SvRV($arg));
    $var = INT2PTR($type, tmp);
  }
  else
    croak(\"$var is not of type ${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\")

T_GRN_OBJ
  if (!SvOK($arg)) {
    ${$var eq 'new_obj' ? \qq{Newx($var, 1, grn_obj); sv_setref_pv($arg, \"Groonga::API::obj\", (void*)$var);} : \qq{$var = NULL;}};
  } else if (sv_derived_from($arg, \"${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\")){
    IV tmp = SvIV((SV*)SvRV($arg));
    $var = INT2PTR($type, tmp);
  } else if (sv_derived_from($arg, \"Groonga::API::obj\")){
    IV tmp = SvIV((SV*)SvRV($arg));
    $var = INT2PTR($type, tmp);
  }
  else
    croak(\"$var is not of type ${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\")

T_GRN_TABLE_SORT_KEY
  if (!SvOK($arg)) {
    $var = NULL;
  } else if (sv_derived_from($arg, \"${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\")){
    IV tmp = SvIV((SV*)SvRV($arg));
    $var = INT2PTR($type, tmp);
  }
  else
    croak(\"$var is not of type ${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\")

T_GRN_IGNORE
  $var = NULL;

T_PV_OR_UNDEF
  if (!SvOK($arg)) {
    $var = NULL;
  } else {
    $var = ($type)SvPV_nolen($arg);
    ${
      ($var eq 'format_with_va_list')
        ? \qq[
          SV *sv = newSV(0);
          int sv_max = items - $argoff - 1;
          SV * args[sv_max];
          int i;
          bool do_taint = FALSE;
          for(i = 0; i < sv_max; i++) {
            args[i] = ST($argoff + 1 + i);
          }
          sv_vsetpvfn(sv, $var, strlen($var), NULL, args, sv_max, &do_taint);
          $var = ($type)SvPV_nolen(sv);
        ]
        : \qq[]
    };
  }

T_OPAQUE_
  $var = ${$var =~ /_pv/ ? \qq{($type)} : \qq{*($type *)}}SvPV_nolen($arg)

T_GRN_LOGGER_INFO
  STMT_START {
    SV* const xsub_tmp_sv = $arg;
    SvGETMAGIC(xsub_tmp_sv);
    if (SvROK(xsub_tmp_sv)) {
      HV* const xsub_tmp_hv = (HV *)SvRV(xsub_tmp_sv);
      static grn_logger_info logger_info;

      if (hv_exists(xsub_tmp_hv, \"max_level\", 9)) {
        SV **value;
        if ((value = hv_fetch(xsub_tmp_hv, \"max_level\", 9, 0)) != NULL) {
          logger_info.max_level = SvIV(*value);
        }
      }
      if (hv_exists(xsub_tmp_hv, \"flags\", 5)) {
        SV **value;
        if ((value = hv_fetch(xsub_tmp_hv, \"flags\", 5, 0)) != NULL) {
          logger_info.flags = SvIV(*value);
        }
      }
      /* TODO: callback support? */
      logger_info.func = NULL;
      logger_info.func_arg = NULL;

      $var = &logger_info;
    }
    else {
      croak(\"%s: %s is not a hash reference\", 
        ${$ALIAS?\q[GvNAME(CvGV(cv))]:\qq[\"$pname\"]},
        \"$var\");
    }
  } STMT_END

T_GRN_CTX_INFO
  if (!SvOK($arg)) {
    Newx($var, 1, grn_ctx_info);
    sv_setref_pv($arg, \"Groonga::API::ctx_info\", (void*)$var);
  } else if (sv_derived_from($arg, \"Groonga::API::ctx_info\")){
    IV tmp = SvIV((SV*)SvRV($arg));
    $var = INT2PTR($type, tmp);
  }
  else
    croak(\"$var is not of type Groonga::API::ctx_info\")

OUTPUT
T_GRN_CTX
  sv_setref_pv($arg, \"Groonga::API::ctx\", (void*)$var);

T_GRN_OBJ
  sv_setref_pv($arg, \"${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\", (void*)$var);

T_GRN_TABLE_SORT_KEY
  sv_setref_pv($arg, \"${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\", (void*)$var);

T_PV_OR_UNDEF
  if ($var != NULL) {
    sv_setpv((SV*)$arg, $var);
  } else {
    $arg = &PL_sv_undef;
  }

T_OPAQUE_
  sv_setpvn($arg, (char *)${ $var =~ /_out(_length_.+)?$/ ? \$var : \qq{\&$var} }, ${ $var =~ /_length_(\w+)/ ? \qq{$1} : \qq{sizeof($var)}});

TYPEMAP
}

1;
