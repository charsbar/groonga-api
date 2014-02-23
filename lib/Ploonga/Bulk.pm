package Ploonga::Bulk;

use strict;
use warnings;
use Carp;
use Groonga::API;
use Groonga::API::Constants qw/:all/;

my %mapping = (
  GRN_DB_BOOL()       => "BOOL",
  GRN_DB_INT8()       => "INT8",
  GRN_DB_UINT8()      => "UINT8",
  GRN_DB_INT16()      => "INT16",
  GRN_DB_UINT16()     => "UINT16",
  GRN_DB_INT32()      => "INT32",
  GRN_DB_UINT32()     => "UINT32",
  GRN_DB_INT64()      => "INT64",
  GRN_DB_UINT64()     => "UINT64",
  GRN_DB_FLOAT()      => "FLOAT",
  GRN_DB_TIME()       => "TIME",
  GRN_DB_SHORT_TEXT() => "SHORT_TEXT",
  GRN_DB_TEXT()       => "TEXT",
  GRN_DB_LONG_TEXT()  => "LONG_TEXT",
);

sub new {
  my ($class, %args) = @_;

  croak "requires ctx" unless $args{ctx};
  $args{_ctx} = $args{ctx}{_obj};

  $args{flags} ||= 0;
  $args{_type} = $mapping{$args{type}};

  $args{_obj} = Groonga::API::obj_open($args{_ctx}, GRN_BULK, $args{flags}, $args{type}) or return;

  my $self = bless \%args, $class;

  $self->init;

  if ($args{value}) {
    $self->set($args{value});
  }

  $self;
}

sub DESTROY {
  my $self = shift;
  Groonga::API::bulk_fin($self->{_ctx}, $self->{_obj});
  Groonga::API::obj_unlink($self->{_ctx}, $self->{_obj});
}

sub obj { shift->{_obj} }

sub init {
  my $self = shift;

  # TODO: RECORD/PTR/VECTOR
  my $type = $self->{_type} or return;
  no strict 'refs';
  &{"Groonga::API::".$type."_INIT"}($self->{_obj}, $self->{flags});
}

sub set {
  my ($self, $value) = @_;

  # TODO: RECORD/PTR/VECTOR
  my $type = $self->{_type} or return;
  if ($type =~ /_TEXT$/) {
    Groonga::API::TEXT_SETS($self->{_ctx}, $self->{_obj}, $value);
  }
  else {
    no strict 'refs';
    &{"Groonga::API::".$type."_SET"}($self->{_ctx}, $self->{_obj}, $value);
  }
}

sub set_at {
  my ($self, $offset, $value) = @_;

  # TODO: RECORD/PTR/VECTOR
  my $type = $self->{_type} or return;
  if ($type =~ /_TEXT$/) {
    croak "ERR: $type does not support set_at";
  }
  else {
    no strict 'refs';
    &{"Groonga::API::".$type."_SET_AT"}($self->{_ctx}, $self->{_obj}, $offset, $value);
  }
}

sub value {
  my $self = shift;

  # TODO: RECORD/PTR/VECTOR
  my $type = $self->{_type} or return;
  if ($type =~ /_TEXT$/) {
    Groonga::API::TEXT_VALUE($self->{_obj});
  } else {
    no strict 'refs';
    &{"Groonga::API::".$type."_VALUE"}($self->{_obj});
  }
}

sub value_at {
  my ($self, $offset, $value) = @_;

  # TODO: RECORD/PTR/VECTOR
  my $type = $self->{_type} or return;
  if ($type =~ /_TEXT$/) {
    croak "ERR: $type does not support value_at";
  }
  else {
    no strict 'refs';
    &{"Groonga::API::".$type."_VALUE_AT"}($self->{_obj}, $offset);
  }
}

1;

__END__

=head1 NAME

Ploonga::Bulk

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
