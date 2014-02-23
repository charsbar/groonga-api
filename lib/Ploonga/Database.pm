package Ploonga::Database;

use strict;
use warnings;
use Carp;
use Groonga::API;
use Groonga::API::Constants qw/:OBJ GRN_CONTENT_JSON/;
use Ploonga::Table;
use JSON::XS;

sub new {
  my ($class, %args) = @_;

  if (!$args{ctx}) {
    require Ploonga::Context;
    $args{ctx} = Ploonga::Context->new;
  }
  $args{_ctx} = $args{ctx}{_obj};

  if (defined $args{path} and -f $args{path}) {
    $args{_obj} = Groonga::API::db_open($args{_ctx}, $args{path})
      or croak "ERR: db_open";
    $args{_opened} = 1;
  }
  else {
    if ($args{no_create} and defined $args{path}) {
      croak "$args{path} does not exist";
    }
    $args{_obj} = Groonga::API::db_create($args{_ctx}, $args{path}, undef)
      or croak "ERR: db_create";
    $args{_created} = 1;
  }

  bless \%args, $class;
}

sub DESTROY {
  my $self = shift;

  if ($self->{_created} or $self->{_opened}) {
    Groonga::API::obj_unlink($self->{_ctx}, $self->{_obj});
  }
}

sub path {
  my $self = shift;
  Groonga::API::obj_path($self->{_ctx}, $self->{_obj});
}

sub table {
  my ($self, $name) = @_;

  Ploonga::Table->new(ctx => $self->{ctx}, name => $name);
}

sub create_table {
  my ($self, %args) = @_;

  if ($self->{path} and $args{name}) {
    $args{flags} |= GRN_OBJ_PERSISTENT;
  }

  Ploonga::Table->create(%args, ctx => $self->{ctx});
}

sub load {
  my ($self, %args) = @_;

  if ($args{values} and ref $args{values}) {
    $args{values} = JSON::XS::encode_json($args{values});
  }

  my $rc; $rc = Groonga::API::load($self->{_ctx}, GRN_CONTENT_JSON,
    map { ($_, defined $_ ? bytes::length($_) : 0) }
    map { $args{$_} }
    qw/table columns values ifexists each/
  ) and croak "ERR: load: $rc";
}

1;

__END__

=head1 NAME

Ploonga::Database

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
