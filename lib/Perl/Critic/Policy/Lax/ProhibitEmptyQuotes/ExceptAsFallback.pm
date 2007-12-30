use strict;
use warnings;

package Perl::Critic::Policy::Lax::ProhibitEmptyQuotes::ExceptAsFallback;

=head1 NAME

Perl::Critic::Policy::Lax::ProhibitEmptyQuotes::ExceptAsFallback

=head1 DESCRIPTION

Sure, C<""> can be confusing when crammed into the middle of a big list of
values, and a bunch of spaces is even worse.  It's really common, though, to
write this code to get a default, false, defined string:

  my $value = $got || '';

It's got a certain charm about it that just isn't manifested by these:

  my $value = $got || $EMPTY;
  my $value = $got || q{};

This policy prohibits all-whitespace strings constructed by single or double
quotes, except for the empty string when it follows the high-precedence "or" or "defined or" operators.

=cut

use Perl::Critic::Utils;
use base qw(Perl::Critic::Policy);

our $VERSION = '0.007';

my $DESCRIPTION = q{Quotes used with an empty string, and not as a fallback};
my $EXPLANATION = "Unless you're using the ||'' idiom, use a quotish form.";

my $empty_rx = qr{\A ["'] (\s*) ['"] \z}x;

sub default_severity { $SEVERITY_LOW       }
sub default_themes   { qw(lax)             }
sub applies_to       { 'PPI::Token::Quote' }

sub violates {
  my ($self, $element, undef) = @_;

  my ($content) = $element =~ $empty_rx;
  return unless defined $content;

  # If the string is truly empty and comes after || or //, that's cool.
  if (not length $content and my $prev = $element->sprevious_sibling) {
    return if $prev->isa('PPI::Token::Operator')
           && grep { $prev eq $_ } ('||', '//');
  }
          
  return $self->violation($DESCRIPTION, $EXPLANATION, $element);
}

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

Adapted from ValuesAndExpressions::ProhibitEmptyQuotes by Jeffrey Ryan
Thalhammer

=head1 COPYRIGHT

Copyright (c) 2006 Ricardo Signes and Jeffrey Ryan Thalhammer.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
