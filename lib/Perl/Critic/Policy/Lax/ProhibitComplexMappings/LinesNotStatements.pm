use strict;
use warnings;

package Perl::Critic::Policy::Lax::ProhibitComplexMappings::LinesNotStatements;

=head1 NAME

Perl::Critic::Policy::Lax::ProhibitComplexMappings::LinesNotStatements

=head1 DESCRIPTION

Yes, yes, don't go nuts with map and use it to implement the complex multi-pass
fnordsort algorithm.  But, come on, guys!  What's wrong with this:

  my @localparts = map { my $addr = $_; $addr =~ s/\@.+//; $addr } @addresses;

Nothing, that's what!

The assumption behind this module is that while the above is okay, the bellow
is Right Out:

  my @localparts = map {
    my $addr = $_;
    $addr =~ s/\@.+//;
    $addr
  } @addresses;

Beyond the fact that it's really ugly, it's just a short step from there to a
few included loop structures and then -- oops! -- a return statement.
Seriously, people, they're called subroutines.  We've had them since Perl 3.

=cut

use Perl::Critic::Utils;
use base qw(Perl::Critic::Policy);

our $VERSION = '0.008';

my $DESCRIPTION = q{The block given to map should fit on one line.};
my $EXPLANATION = "If it doesn't fit on one line, turn it into a subroutine.";

sub default_severity { $SEVERITY_MEDIUM    }
sub default_themes   { qw(lax complexity)  }
sub applies_to       { 'PPI::Token::Word'  }

sub violates {
  my ($self, $element, undef) = @_;

  return if $element ne 'map';
  return if !is_function_call($element);

  my $sib = $element->snext_sibling();
  return if !$sib;

  my $arg = $sib;
  if ($arg->isa('PPI::Structure::List')) {
    $arg = $arg->schild(0);

  # Forward looking: PPI might change in v1.200 so schild(0) is a
  # PPI::Statement::Expression
    if ($arg && $arg->isa('PPI::Statement::Expression')) {
      $arg = $arg->schild(0);
    }
  }

  # If it's not a block, it's an expression-style map, which is only one
  # statement by definition
  return if !$arg;
  return if !$arg->isa('PPI::Structure::Block');

  # The moment of truth: does the block contain any newlines?
  return unless $arg =~ /[\x0d\x0a]/;

  # more than one child statements
  return $self->violation($DESCRIPTION, $EXPLANATION, $element);
}

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

Adapted from BuiltinFunctions::ProhibitComplexMappings by Chris Dolan.

=head1 COPYRIGHT

Copyright (c) 2006 Ricardo Signes and Chris Dolan.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
