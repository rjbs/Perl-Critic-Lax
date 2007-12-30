use strict;
use warnings;

package Perl::Critic::Policy::Lax::ProhibitLeadingZeros::ExceptChmod;

=head1 NAME

Perl::Critic::Policy::Lax::ProhibitLeadingZeros::ExceptChmod

=head1 DESCRIPTION

This is a stupid mistake:

  my $x = 1231;
  my $y = 2345;
  my $z = 0032;

This is not:

  chmod 0600, "secret_file.txt";

=cut

use Perl::Critic::Utils;
use base qw(Perl::Critic::Policy);

our $VERSION = '0.007';

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

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

Adapted from ValuesAndExpressions::ProhibitLeadingZeros by Jeffrey Ryan
Thalhammer.

=head1 COPYRIGHT

Copyright (c) 2007 Ricardo Signes and Jeffrey Ryan Thalhammer.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
