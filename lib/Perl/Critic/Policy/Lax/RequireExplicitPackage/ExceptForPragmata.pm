use strict;
use warnings;

package Perl::Critic::Policy::Lax::RequireExplicitPackage::ExceptForPragmata;

=head1 NAME

Perl::Critic::Policy::Lax::RequireExplicitPackage::ExceptForPragmata

=head1 VERSION

version 0.003

=head1 DESCRIPTION

This policy is meant to replace Modules::RequireExplicitPackage.  That policy's
POD says:

  In general, the first statement of any Perl module or library should be a
  package statement.  Otherwise, all the code that comes before the package
  statement is getting executed in the caller's package, and you have no idea
  who that is.  Good encapsulation and common decency require your module to
  keep its innards to itself.

Sure, that's swell for code that has effect at a package level, but some
statements are lexical.  This policy makes allowance for just one of those
cases: turning on strictures, warnings, and diagnostics.

This module understands the C<exempt_scripts> configuration parameter just like
L<Perl::Critic::Policy::Modules::RequireExplicitPackage>.

=cut

use Perl::Critic::Utils;
use base qw(Perl::Critic::Policy);

our $VERSION = '0.003';

my $EXPLANATION = 'Violates encapsulation';
my $DESCRIPTION = 'Code (other than strict/warnings) not in explicit package';

sub default_severity { return $SEVERITY_HIGH  }
sub default_themes   { return qw( risky )     }
sub applies_to       { return 'PPI::Document' }

sub new {
  my ($class, %args) = @_;
  my $self = bless {}, $class;

  #Set config, if defined
  $self->{_exempt_scripts} =
    defined $args{exempt_scripts} ? $args{exempt_scripts} : 1;

  return $self;
}

# TODO: Make this configurable. -- rjbs, 2006-11-07
my %allowed_pragmata = (
  diagnostics => 1,
  strict      => 1,
  warnings    => 1,
);

sub violates {
  my ($self, $elem, $doc) = @_;

  # You can configure this policy to exclude scripts
  return if $self->{_exempt_scripts} && is_script($doc);

  # Find the first 'package' statement
  my $package_stmnt = $doc->find_first('PPI::Statement::Package');
  my $package_line = $package_stmnt ? $package_stmnt->location()->[0] : undef;

  # Find all statements that aren't 'package' statements
  my $stmnts_ref = $doc->find('PPI::Statement');
  return if !$stmnts_ref;
  my @non_packages =
    grep { not(
      $_->isa('PPI::Statement::Include') && $_->type eq 'use'
      && exists $allowed_pragmata{ $_->module }
    ) }
    grep { !$_->isa('PPI::Statement::Package') } @{$stmnts_ref};
  return if !@non_packages;

  # If the 'package' statement is not defined, or the other
  # statements appear before the 'package', then it violates.

  my @viols = ();
  for my $statement (@non_packages) {
    my $statement_line = $statement->location->[0];
    if ((not defined $package_line) || ($statement_line < $package_line)) {
      push @viols, $self->violation($DESCRIPTION, $EXPLANATION, $statement);
    }
  }

  return @viols;
}

1;

__END__

=pod

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

Adapted from Modules::RequireExplicitPackage by Jeffrey Ryan Thalhammer.

=head1 COPYRIGHT

Copyright (c) 2006 Ricardo SIGNES and Jeffrey Ryan Thalhammer.  All rights
reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
