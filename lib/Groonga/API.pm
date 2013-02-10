package Groonga::API;

use strict;
use warnings;
use XSLoader;

our $VERSION = '0.01';

XSLoader::load(__PACKAGE__, $VERSION);

our $GRN_VERSION = get_version();
our $GRN_MAJOR_VERSION = (split /\./, $GRN_VERSION)[0];

sub get_major_version { $GRN_MAJOR_VERSION }

1;

__END__

=head1 NAME

Groonga::API - raw interface to groonga

=head1 DESCRIPTION

Groonga::API is a very B<thin> wrapper of groonga C APIs. All it does is to map types, and it's not meant to be used by a casual perl user. Try L<Ploonga> for ordinary use.

If you really need to do something that can't be done with a standard groonga client, welcome. As this doesn't expose all of the "public" APIs yet, if you want anything more, send me a typemap patch (see L<perlxstypemap> for a starter) and some tests (or ask the groonga developers to expose an appropriate API for your need).

To use this module, you naturally need to read groonga.h and other groonga source files (reading online documents is not enough at all).

=head1 SEE ALSO

L<Ploonga>

L<http://groonga.org/>

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
