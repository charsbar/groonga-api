package Ploonga::Column;

use strict;
use warnings;
use Carp;
use Groonga::API;
use Groonga::API::Constants qw/
  GRN_TABLE_MAX_KEY_SIZE
/;

sub new {
  my ($class, %args) = @_;

  croak "requires ctx" unless $args{ctx};
  $args{_ctx} = $args{ctx}{_obj};

  croak "requires table" unless $args{table};

  my $name = $args{name};
  croak "requires name" unless defined $name;
  $args{_obj} = Groonga::API::obj_column($args{_ctx}, $args{table}, $name, bytes::length($name)) or return;
  $args{_opened} = 1;

  bless \%args, $class;
}

sub create {
  my ($class, %args) = @_;

  croak "requires ctx" unless $args{ctx};
  $args{_ctx} = $args{ctx}{_obj};

  my $name = $args{name};
  my $name_size = defined $name ? bytes::length($name) : 0;
  my $type_id = $args{type};
  if (defined $type_id and !ref $type_id) {
    $args{type} = $args{ctx}->type($type_id);
  }
  elsif (ref $type_id =~ /^Ploonga::/) { # table of any kind
    $args{type} = $type_id->{_obj};
  }
  $args{flags} ||= 0;

  $args{_obj} = Groonga::API::column_create($args{_ctx}, $args{table}, $name, $name_size, $args{path}, $args{flags}, $args{type}) or return;
  $args{_created} = 1;

  bless \%args, $class;
}

sub DESTROY {
  my $self = shift;
  if (my $ctx = $self->{_ctx}) {
    Groonga::API::obj_unlink($ctx, $self->{_obj});
  }
}

sub name {
  my $self = shift;
  my $buf = " " x GRN_TABLE_MAX_KEY_SIZE;
  my $len = Groonga::API::column_name($self->{_ctx}, $self->{_obj}, $buf, bytes::length($buf));
  substr($buf, 0, $len);
}

sub rename {
  my ($self, $name) = @_;
  my $rc; $rc = Groonga::API::column_rename($self->{_ctx}, $self->{_obj}, $name, bytes::length($name))
    and croak "ERR: column_rename: $rc";
}

1;

__END__

=head1 NAME

Ploonga::Column

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
