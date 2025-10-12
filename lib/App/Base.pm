package MERM::Base;

use 5.018;
use strict;
use warnings;
use Carp;
use lib 'lib';

use version; our $VERSION = version->declare("v1.0.11");

use Exporter   qw( );
use List::Util qw( uniq );

our @EXPORT      = ();
our @EXPORT_OK   = ();
our %EXPORT_TAGS = ( all => \@EXPORT_OK );    # Optional.

sub import {
    my $class = shift;
    my (@packages) = @_;

    my ( @pkgs, @rest );
    for (@packages) {
        if (/^::/) {
            push @pkgs, __PACKAGE__ . $_;
        }
        else {
            push @rest, $_;
        }
    }

    for my $pkg (@pkgs) {
        my $mod = ( $pkg =~ s{::}{/}gr ) . ".pm";
        require $mod;

        my $exports = do { no strict "refs"; \@{ $pkg . "::EXPORT_OK" } };
        $pkg->import(@$exports);
        @EXPORT    = uniq @EXPORT,    @$exports;
        @EXPORT_OK = uniq @EXPORT_OK, @$exports;
    }

    @_ = ( $class, @rest );
    goto &Exporter::import;
}

1;    # End of MERM::Base

=pod

=encoding utf-8

=head1 NAME

MERM::Base - Base modules for Perl Development


=head1 VERSION

Version v.1.0.11

=head1 SYNOPSIS

MERM::Base provides a loader for sub-modules where a leading :: denotes a package to load.

    use MERM::Base qw( ::OS ::Utils );

This is equivalent to:

    user MERM::Base::OS    qw(:all);
    user MERM::Base::Utils qw(:all);



=head1 SEE ALSO

L<MERM::Base::Disks>,
L<MERM::Base::Syntax>,
L<MERM::Base::Utils>,
L<MERM::Base::OS>,
L<MERM::Base::Backup>

=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.



=back


=head1 CONFIGURATION AND ENVIRONMENT

MERM::Base requires no configuration files or environment variables.


=head1 DEPENDENCIES

None.


=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS


No bugs have been reported.

Please report any bugs or feature requests to
C<bug-merm-base@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Matt Martini  C<< <matt@imaginarywave.com> >>


=head1 LICENCE AND COPYRIGHT

This software is Copyright © 2024 by Matt Martini.

This is free software, licensed under:

  The GNU General Public License, Version 3, June 2007

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

__END__
