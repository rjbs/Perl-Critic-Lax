use strict;
use warnings;
package Perl::Critic::Policy::Lax::ProhibitLeadingZeros::ExceptChmod;
# ABSTRACT: leading zeroes are okay as the first arg to chmod

=head1 DESCRIPTION

This is a stupid mistake:

  my $x = 1231;
  my $y = 2345;
  my $z = 0032;

This is not:

  chmod 0600, "secret_file.txt";

=cut

use Perl::Critic::Utils;
use parent qw(Perl::Critic::Policy);

my $DESCRIPTION = q{Integer with leading zeros outside of chmod};
my $EXPLANATION = "Only use leading zeros on numbers indicating file modes";

sub default_severity { $SEVERITY_MEDIUM     }
sub default_themes   { qw(lax bugs)         }
sub applies_to       { 'PPI::Token::Number' }

my $LEADING_ZERO_RE = qr{\A [+-]? (?: 0+ _* )+ [1-9]}mx;

sub violates {
  my ($self, $element, undef) = @_;

  return unless $element =~ $LEADING_ZERO_RE;
  return if $element->sprevious_sibling eq 'chmod';

  my $working = eval { $element->parent->parent };
  if ($element->parent->isa('PPI::Statement::Expression')) {
    my $working = $element->parent->parent;
    while (eval { $working->isa('PPI::Structure::List') }) {
      $working = $working->parent;
    }

    return if $working and ($working->children)[0] eq 'chmod';
  }

  return $self->violation($DESCRIPTION, $EXPLANATION, $element);
}

1;
