package inc::GroongaAPIUtil::Exports;

use strict;
use warnings;

sub write {
  my $env = shift;
  my $dir = $env->{dir};
  my @export_ok = @{$env->{to_export} || []};

  push @export_ok, qw/
    get_major_version
    EXPR_CREATE_FOR_QUERY
    CHAR_TYPE CHAR_IS_BLANK 
    TEXT_LEN
  /;

  my %tags = (all => \@export_ok);

  open my $out, '>', "$dir/lib/Groonga/API/Exports.pm" or die "Can't open Exports.pm: $!";
  my $export_ok = join " ", sort @export_ok;
  my $export_tags = join ",\n  ",
    map {"$_ => [qw/" . join(" ", sort @{$tags{$_} || []}) ."/]"}
    sort keys %tags;

    print $out <<"END";
package Groonga::API::Exports;
use strict;
use warnings;
our \@EXPORT_OK = qw($export_ok);
our \%EXPORT_TAGS = (
  $export_tags
);
1;

__END__

=head1 NAME

Groonga::API::Exports

=head1 AUTHOR

Kenichi Ishigaki, E<lt>ishigaki\@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Kenichi Ishigaki.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
END
}

1;
