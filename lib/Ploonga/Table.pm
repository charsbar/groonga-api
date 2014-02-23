package Ploonga::Table;

use strict;
use warnings;
use Carp;
use Groonga::API;
use Groonga::API::Constants qw/
  GRN_OBJ_SET
  GRN_OBJ_PERSISTENT
  GRN_OBJ_KEY_NORMALIZE
  GRN_INFO_DEFAULT_TOKENIZER
  GRN_INFO_NORMALIZER
/;
use Ploonga::Bulk;
use Ploonga::Column;

sub new {
  my ($class, %args) = @_;

  croak "requires ctx" unless $args{ctx};
  $args{_ctx} = $args{ctx}{_obj};

  my $name = $args{name};
  croak "requires name" unless defined $name;
  $args{_obj} = Groonga::API::ctx_get($args{_ctx}, $name, bytes::length($name)) or return;
  $args{_opened} = 1;

  bless \%args, $class;
}

sub create {
  my ($class, %args) = @_;

  croak "requires ctx" unless $args{ctx};
  $args{_ctx} = $args{ctx}{_obj};

  my $name = $args{name};
  my $name_size = defined $name ? bytes::length($name) : 0;
  for (qw/key_type value_type/) {
    my $type_id = $args{$_};
    if (defined $type_id and !ref $type_id) {
      $args{$_} = $args{ctx}->type($type_id);
    }
  }
  if ($args{normalize}) {
    # TODO: use obj_set_info(..., GRN_INFO_NORMALIZER, ...)
    $args{flags} |= GRN_OBJ_KEY_NORMALIZE;
  }

  $args{_obj} = Groonga::API::table_create($args{_ctx}, $name, $name_size, $args{path}, $args{flags}, $args{key_type}, $args{value_type}) or return;
  $args{_created} = 1;

  if ($args{tokenizer}) {
    my $tokenizer = Groonga::API::ctx_at($args{_ctx}, $args{tokenizer})
      or croak "ERR: tokenizer not found: $args{tokenizer}";
    my $rc; $rc = Groonga::API::obj_set_info($args{_ctx}, $args{_obj}, GRN_INFO_DEFAULT_TOKENIZER, $tokenizer)
      and croak "ERR: obj_set_info(tokenizer): $rc";
  }

  bless \%args, $class;
}

sub DESTROY {
  my $self = shift;
  if ($self->{_created} or $self->{_opened}) {
    Groonga::API::obj_unlink($self->{_ctx}, $self->{_obj});
  }
}

sub rename {
  my ($self, $name) = @_;

  my $rc; $rc = Groonga::API::table_rename($self->{_ctx}, $self->{_obj}, $name, bytes::length($name))
    and croak "ERR: table_rename: $rc";
}

sub column {
  my ($self, $name) = @_;

  Ploonga::Column->new(ctx => $self->{ctx}, table => $self->{_obj}, name => $name);
}

sub create_column {
  my ($self, %args) = @_;

  Ploonga::Column->create(%args, ctx => $self->{ctx}, table => $self->{_obj});
}

sub size {
  my $self = shift;

  Groonga::API::table_size($self->{_ctx}, $self->{_obj});
}

sub add {
  my ($self, $key, %columns) = @_;

  my ($ctx, $table) = ($self->{_ctx}, $self->{_obj});
  my $id = Groonga::API::table_add($ctx, $table, $key, bytes::length($key), my $added);
  for my $name (keys %columns) {
    my $column;
    if ($name eq '_value') {
      $column = $table;
    }
    else {
      $column = Groonga::API::obj_column($ctx, $table, $name, bytes::length($name)) or croak "ERR: obj_column: $name";
    }
    my $range = Groonga::API::obj_get_range($ctx, $column);

    # TODO: vector support
    my $bulk = Ploonga::Bulk->new(
      ctx => $self->{ctx},
      type => $range,
      value => $columns{$name},
    );

    Groonga::API::obj_set_value($ctx, $column, $id, $bulk->obj, GRN_OBJ_SET);
  }
}

sub delete {
  my ($self, $key) = @_;
  my $rc; $rc = Groonga::API::table_delete($self->{_ctx}, $self->{_obj}, $key, bytes::length($key)) and croak "ERR: table_delete: $rc";
}

sub defrag {
  my ($self, $threshold) = @_;
  Groonga::API::obj_defrag($self->{_ctx}, $self->{_obj}, $threshold);
}

1;

__END__

=head1 NAME

Ploonga::Table

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS

=head2 new

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
