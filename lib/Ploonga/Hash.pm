package Ploonga::Hash;

use strict;
use warnings;
use Carp;
use Groonga::API;

sub new {
  my ($class, %args) = @_;

  if (!$args{ctx}) {
    require Ploonga::Context;
    $args{ctx} = Ploonga::Context->new;
  }

  if (defined $args{path} and -f $args{path}) {
    $args{obj} = Groonga::API::hash_open(@args{qw/ctx path/});
      or croak "ERR: hash_open";
  }
  else {
    if ($args{no_create} and defined $args{path}) {
      croak "$args{path} does not exist";
    }
    $args{obj} = Groonga::API::hash_create(@args{qw/ctx path key_size value_size/})
      or croak "ERR: hash_create";
  }

  bless \%args, $class;
}

sub DESTROY {
  my $self = shift;
  if ($self->{obj}) {
    Groonga::API::hash_close(@$self{qw/ctx obj/});
  }
}

1;

__END__

=head1 NAME

Ploonga::Hash

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
