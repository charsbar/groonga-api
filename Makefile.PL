use strict;
use warnings;
use FindBin;
use ExtUtils::MakeMaker;

# use Devel::CheckLib for sure?

my ($groonga_h, $inc, $libs) = check_env() or do {
  warn "groonga.h is not found; install groonga and/or set GROONGA_INC/GROONGA_LIBS environmental variables if necessary\n";
  exit(0);  # N/A
};

extract_constants($groonga_h);
extract_apis($groonga_h);

my %params = (
  NAME          => 'Groonga::API',
  AUTHOR        => 'Kenichi Ishigaki <ishigaki@cpan.org>',
  VERSION_FROM  => 'lib/Groonga/API.pm',
  ABSTRACT_FROM => 'lib/Groonga/API.pm',
  LICENSE       => 'perl',
  OBJECT        => '$(O_FILES)',
  PREREQ_PM     => {
    'Exporter'            => 0,
    'JSON::XS'            => 0,
    'Path::Extended'      => 0,
    'Test::Differences'   => 0,
    'Test::More'          => '0.88',
    'Test::UseAllModules' => '0.10',
  },
  META_MERGE => {
    resources => {
      repository => 'https://github.com/charsbar/groonga-api',
    },
  },
  test => {TESTS => 't/*.t t/*/*.t'},
);

$params{INC}  = $inc  if $inc;
$params{LIBS} = $libs if $libs;

my $eumm = $ExtUtils::MakeMaker::VERSION;
delete $params{LICENSE}          if $eumm < 6.31;
delete $params{META_MERGE}       if $eumm < 6.46;

WriteMakefile(%params);

#------------
# utilities
#------------

sub check_env {
  my ($groonga_h, $inc, $libs);

  my @incpath = qw(/usr/local/include /usr/include);
  if ($ENV{GROONGA_INC}) {
    my $inc = $ENV{GROONGA_INC};
    $inc =~ s|^["']||;
    $inc =~ s|["']$||;
    $inc =~ s/^\-I//;
    $inc =~ s|\\|/|g;
    $inc =~ s|/$||g;
    unshift @incpath, $inc;
  }
  for (@incpath) {
    if (-e "$_/groonga/groonga.h") {
      $groonga_h = "$_/groonga/groonga.h";
      $inc = $_;
      last;
    }
  }
  return unless $groonga_h;

  (my $lib = $inc) =~ s|include$|lib|;
  $libs = $ENV{GROONGA_LIBS} || "-L$lib -lgroonga";
  $inc  = $ENV{GROONGA_INC}  || "-I$inc";

  return ($groonga_h, $inc, $libs);
}

sub extract_constants {
  my $groonga_h = shift;

  my $h = do {
    open my $fh, '<', $groonga_h or die "Can't open groonga.h: $!";
    local $/;
    <$fh>;
  };

  my @typedefs = $h =~ /typedef\s+enum\s*\{(.+?)\}\s*(\w+);/sg;
  my %seen;
  my %tags;
  my %ignore = map { $_ => 1 } qw/
    GRN_API GRN_INFO_CONFIGURE_OPTIONS GRN_INFO_CONFIG_PATH
    GRN_SNIP_MAPPING_HTML_ESCAPE GRN_NORMALIZER_AUTO
  /;

  while(my ($def, $tag) = splice @typedefs, 0, 2) {
    $tag =~ s/^grn_//;
    $def =~ s!/\*.+?\*/!!gs;
    $def =~ s!^#define .+!!mg;
    for (split /\s*,\s*/s, $def) {
      s/\s*=.+$//;
      s/^\s+//s;
      s/\s+$//s;
      next unless /^[A-Z0-9_]+$/;
      next if $ignore{$_};
      die "seen $_" if $seen{$_}++;
      push @{$tags{uc $tag} ||= []}, $_;
    }
  }

  my @defines_to_ignore = $h =~ /^#define\s+(GRN_[A-Z0-9_]+)\(/mg;
  for (@defines_to_ignore) {
    $ignore{$_} = 1;
  }

  my @defines_alias = $h =~ /^#define\s+(GRN_[A-Z0-9_]+\s+GRN_[A-Z0-9_]+)/mg;
  for (@defines_alias) {
    my ($def, $alias) = split /\s/;
    $ignore{$def} = 1 if $ignore{$alias};
  }

  my @defines = $h =~ /^#define\s+(GRN_[A-Z0-9_]+)/mg;

  for (@defines) {
    next if $ignore{$_};
    die "seen $_" if $seen{$_}++;
    push @{$tags{$1} ||= []}, $_ if /^GRN_(ID|COMMAND_VERSION|QUERY_LOG|OBJ_FORMAT|OBJ|CURSOR|TABLE_GROUP|TABLE|COLUMN|QUERY|SNIP|LOG|STRING|STR|EXPR|CTX)_/;
  }

  $tags{BOOL} = [qw/GRN_TRUE GRN_FALSE/];
  $tags{OBJ_TYPES} = [qw/GRN_VOID GRN_BULK GRN_PTR GRN_UVECTOR GRN_PVECTOR GRN_VECTOR GRN_MSG GRN_QUERY GRN_ACCESSOR GRN_ACCESSOR_VIEW GRN_SNIP GRN_PATSNIP GRN_STRING GRN_CURSOR_TABLE_HASH_KEY GRN_CURSOR_TABLE_PAT_KEY GRN_CURSOR_TABLE_DAT_KEY GRN_CURSOR_TABLE_NO_KEY GRN_CURSOR_TABLE_VIEW GRN_CURSOR_COLUMN_INDEX GRN_CURSOR_COLUMN_GEO_INDEX GRN_TYPE GRN_PROC GRN_EXPR GRN_TABLE_HASH_KEY GRN_TABLE_PAT_KEY GRN_TABLE_DAT_KEY GRN_TABLE_NO_KEY GRN_TABLE_VIEW GRN_DB GRN_COLUMN_FIX_SIZE GRN_COLUMN_VAR_SIZE GRN_COLUMN_INDEX/];

  $tags{all} = [sort keys %seen];

  {
    open my $out, '>', "$FindBin::Bin/constants.inc" or die "Can't open constants.inc: $!";
    my $alias = join "\n", map {"    $_ = $_"} sort keys %seen;
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

  {
    open my $out, '>', "$FindBin::Bin/lib/Groonga/API/Constants.pm" or die "Can't open Constants.pm";
    my $export_ok = join " ", sort keys %seen;
    my $export_tags = join ",\n  ",
      map {"$_ => [qw/" . join(" ", sort @{$tags{$_} || []}) ."/]"}
      sort keys %tags;

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
} # end of extract_constants()

sub extract_apis {
  my $groonga_h = shift;

  my $h = do {
    open my $fh, '<', $groonga_h or die "Can't open groonga.h: $!";
    local $/;
    <$fh>;
  };
  my @apis = $h =~ /\nGRN_API ([^;]+;)/gs;
  printf "Found %d APIs\n", scalar @apis;

  my %types;
  my $supported = 0;

  my %todo = map {("grn_$_" => 1)} (

    # TODO: column
    qw/column_index_update /,

    # TODO: obj
    qw/obj_check obj_clear_lock obj_columns obj_db obj_defrag obj_delete_by_id obj_expire obj_get_range obj_get_value obj_is_locked obj_lock obj_name obj_path obj_path_by_id obj_reinit obj_remove obj_rename obj_set_value obj_unlock/,

    # TODO: array
    qw/array_create array_open array_close array_cursor_close array_cursor_next array_cursor_open array_cursor_set_value array_get_value array_next array_set_value array_push array_pull/,

    # TODO: dat
    qw/dat_close dat_create dat_cursor_close dat_cursor_next dat_cursor_open dat_get_key dat_get_key2 dat_open dat_remove dat_size dat_update dat_update_by_id/,

    # TODO: expr
    qw/expr_add_var expr_alloc expr_append_const expr_append_const_int expr_append_const_str expr_append_obj expr_append_op expr_close expr_compile expr_create expr_exec expr_get_var expr_get_var_by_offset/,

    # TODO: geo
    qw/geo_cursor_next geo_cursor_open_in_rectangle geo_estimate_in_rectangle geo_select_in_rectangle/,

    # TODO: index
    qw/index_cursor_open/,

    # TODO: output_envelope
    qw/output_envelope/,

    # TODO: pat
    qw/pat_close pat_create pat_cursor_close pat_cursor_next pat_cursor_open pat_cursor_set_value pat_get_key pat_get_key2 pat_get_value pat_lcp_search pat_open pat_prefix_search pat_remove pat_set_value pat_size pat_suffix_search/,

    # TODO: plugin
    qw/plugin_register plugin_register_by_path/,

    # TODO: str (obsolete)
    qw/str_close str_open/,

    # TODO: string
    qw/string_get_encoding string_get_flags string_open string_set_normalized string_set_types/,

    # TODO: vector
    qw/vector_add_element vector_size/,

    # TODO: util?
    qw/charlen time_now/,

    # TODO: ctx_output
    qw/ctx_output_array_close ctx_output_array_open ctx_output_bool ctx_output_cstr ctx_output_float ctx_output_int32 ctx_output_int64 ctx_output_map_close ctx_output_map_open ctx_output_str/,

    # TODO: ctx
    qw/ctx_pop ctx_push/,

    # TODO: db
    qw/db_touch/,

    # TODO table
    qw/table_columns/,

    # grn_proc_func
    qw/ctx_set_finalizer proc_create obj_set_finalizer/,

    # grn_expr_var
    qw/proc_create proc_get_info/,

    # grn_id * (short int *)
    qw/index_cursor_next vector_get_element/,

    # grn_table_group_result *
    qw/table_group/,

    # grn_info_type
    qw/obj_get_info obj_set_info obj_get_element_info obj_set_element_info/,

    # get_hook_entry
    qw/obj_add_hook obj_get_nhooks obj_get_hook obj_delete_hook/,

    # grn_snip_mapping *
    qw/snip_open expr_snip/,

    # grn_snip
    qw/snip_open snip_close snip_add_cond snip_exec snip_get_result expr_snip/,

    # grn_query_logger *
    qw/query_logger_set/,

    # grn_object_format *
    qw/output_obj ctx_output_obj/,

    # grn_table_sort_key *
    qw/table_sort table_sort_key_from_str table_sort_key_close/,

    # grn_user_data *
    qw/obj_user_data/,

    # grn_logger *
    qw/logger_set/,

    # grn_ctx_info *
    qw/ctx_info_get/,

    # table_delete_optarg *
    qw/array_cursor_delete array_delete_by_id pat_delete_by_id pat_delete pat_delete_with_sis pat_cursor_delete dat_delete_by_id dat_delete dat_cursor_delete/,

    # grn_search_optarg *
    qw/obj_search/,

    # int *
    qw/column_index pat_add dat_add/,

    # short *
    qw/string_set_checks/,

    # unsigned int *
    qw/string_get_original string_get_normalized table_sort_key_from_str /,

    # const unsigned char *
    qw/string_get_types/,

    # const short *
    qw/string_get_checks/,

    # const char **
    qw/vector_get_element string_get_original string_get_normalized pat_scan/,

    # void **
    qw/obj_get_values array_add array_cursor_get_value pat_get pat_add pat_cursor_get_key pat_cursor_get_value pat_cursor_get_key_value dat_get dat_add dat_cursor_get_key/,

    # functions
    qw/ctx_recv_handler_set/,

    # procs
    qw/proc_get_hook_local_data proc_get_ctx_local_data proc_call_next/,

    # obsolete
    qw/text_otoj/,

    # removed or changed (1.x.x)
    qw/query_rest query_scan query_snip/,

  ); # end of %todo

  my %inout = (
    grn_table_add => {'int *added' => 'OUT int added_out'},
    grn_table_get_key => 'void *keybuf',
    grn_table_cursor_get_key => {'void **key' => 'OUT void *key_out'},
    grn_table_cursor_get_value => {'void **value' => 'OUT void *value_out'},
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
    grn_hash_get_key => 'void *keybuf',
    grn_hash_get_key2 => 'grn_obj *bulk_out',
    grn_hash_get_value => 'void *valuebuf',
    grn_hash_cursor_get_key => {'void **key' => 'OUT void *key_out'},
    grn_hash_cursor_get_value => {'void **value' => 'OUT void *value_out'},
    grn_hash_cursor_get_key_value => {
      'void **key' => 'OUT void *key_out',
      'unsigned int *key_size' => 'OUT unsigned int key_size_out',
      'void **value' => 'OUT void *value_out',
    },
  );

  {
    open my $out, '>', "$FindBin::Bin/api.inc" or die "Can't open api.inc: $!";
    for (@apis) {
      s/\s\s+/ /gs;
      s/\(void\)/()/g;
      s/\s+[A-Z][A-Z_]+\([^)]+\);/;/;
      my ($type, $decl) = split / /, $_, 2;
      if ($decl =~ /^grn_/) {
      } elsif ($decl =~ s/^(.+?)(_?grn_)/$2/) {
        $type .= " $1";
      }
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

      if ($todo{$name}) {
        print $out "# $type\n# $decl\n\n";
      } else {
        $types{$type} = 1;
        print $out "$type\n$decl\n\n";
        $supported++;
      }
    }
  }
  printf "Supported %d APIs\n", $supported;

  my %map = (
    'grn_ctx *' => 'T_GRN_CTX',
    'grn_obj *' => 'T_GRN_OBJ',
  );
  my %grn_extra = (
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
  );
  my %extra = (
    'long long int' => 'T_IV',
    'const void *' => 'T_PV_OR_UNDEF',
    'const char *' => 'T_PV_OR_UNDEF',
    'void *' => 'T_OPAQUE_',
  );

  {
    open my $out, '>', "$FindBin::Bin/typemap" or die "Can't open typemap";
    print $out "TYPEMAP\n";
    for (sort keys %types) {
      if (/^grn_/) {
        if ($map{$_}) {
          print $out $_, "\t", $map{$_}, "\n";
        } elsif (/\*$/) {
          print $out $_, "\t", "T_GRN_OBJ\n";
        } else {
          print $out $_, "\t", "T_ENUM\n";
        }
      }
    }
    for (sort keys %grn_extra) {
      print $out $_, "\t", $grn_extra{$_}, "\n";
    }
    for (sort keys %extra) {
      print $out $_, "\t", $extra{$_}, "\n";
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
  }

T_OPAQUE_
  $var = *($type *)SvPV_nolen($arg)

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

OUTPUT
T_GRN_CTX
  sv_setref_pv($arg, \"Groonga::API::ctx\", (void*)$var);

T_GRN_OBJ
  sv_setref_pv($arg, \"${(my $t=$type)=~s/^grn_/Groonga::API::/;$t=~s/\s*\*+$//;\$t}\", (void*)$var);

T_PV_OR_UNDEF
  if ($var != NULL) {
    sv_setpv((SV*)$arg, $var);
  } else {
    $arg = &PL_sv_undef;
  }

T_OPAQUE_
  sv_setpvn($arg, (char *)${ $var =~ /_out$/ ? \$var : \qq{\&$var} }, sizeof($var));

TYPEMAP
  }
} # end of extract_apis
