use strict;
use warnings;
package Perl::Critic::Policy::Lax::ProhibitLeadingZeros::ExceptChmod;
# ABSTRACT: leading zeroes are okay as the first arg to chmod

=head1 DESCRIPTION

This is subclass of
L<Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros> with no
changes.  It once allowed leading zeroes on numbers used as args to C<chmod>,
but in 2008 the default Perl::Critic policy became to allow leading zeroes
there and in a few other places.

=cut

use Perl::Critic::Utils;
use parent qw(Perl::Critic::Policy::ValuesAndExpressions::ProhibitLeadingZeros);

1;
