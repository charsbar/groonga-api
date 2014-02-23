package Ploonga::Context;

use strict;
use warnings;
use Carp;
use Groonga::API;
use Groonga::API::Constants qw/GRN_CTX_USE_QL/;

sub new {
  my ($class, %args) = @_;
  $args{_obj} = Groonga::API::ctx_open(GRN_CTX_USE_QL)
    or croak "ERR: ctx_open";
  bless \%args, $class;
}

sub DESTROY {
  my $self = shift;
  if (my $ctx = $self->{_obj}) {
    if ($self->{_types}) {
      for (keys %{$self->{_types}}) {
        Groonga::API::obj_unlink($ctx, $self->{_types}{$_});
      }
    }
    Groonga::API::ctx_close($ctx);
  }
}

sub info {
  my $self = shift;
  my $rc; $rc = Groonga::API::ctx_info_get($self->{_obj}, my $info)
    and croak "ERR: ctx_info_get: $rc";
  return $info;
}

sub match_escalation_threshold {
  my $self = shift;
  if (@_) {
    my $rc; $rc = Groonga::API::ctx_set_match_escalation_threshold($self->{_obj}, shift)
      and croak "ERR: ctx_set_match_escalation_threshold: $rc";
  }
  Groonga::API::ctx_get_match_escalation_threshold($self->{_obj});
}

sub command_version {
  my $self = shift;
  if (@_) {
    my $rc; $rc = Groonga::API::ctx_set_command_version($self->{_obj}, shift)
      and croak "ERR: ctx_set_command_version: $rc";
  }
  Groonga::API::ctx_get_command_version($self->{_obj});
}

sub type {
  my ($self, $type_id) = @_;

  unless ($self->{_types}{$type_id}) {
    $self->{_types}{$type_id} = Groonga::API::ctx_at($self->{_obj}, $type_id);
  }
  $self->{_types}{$type_id};
}

sub do {
  my ($self, $command, $flags) = @_;

  my $ctx = $self->{_obj};
  Groonga::API::ctx_send($ctx, $command, bytes::length($command), $flags ||= 0);
  Groonga::API::ctx_recv($ctx, my $res, my $len, my $res_flags);

  return substr($res, 0, $len);
}

1;

__END__

=head1 NAME

Ploonga::Context

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
