use strict;
use warnings;

package Perl::Critic::Policy::Lax::RequireExplicitPackage::ExceptForPragmata;

=head1 NAME

Perl::Critic::Policy::Lax::RequireExplicitPackage::ExceptForPragmata

=head1 VERSION

version 0.008

=head1 DESCRIPTION

This policy is meant to replace Modules::RequireExplicitPackage.  That policy's
POD says:

  In general, the first statement of any Perl module or library should be a
  package statement.  Otherwise, all the code that comes before the package
  statement is getting executed in the caller's package, and you have no idea
  who that is.  Good encapsulation and common decency require your module to
  keep its innards to itself.

Sure, that's swell for code that has effect at a package level, but
some statements are lexical.  This policy makes allowance for some of
those cases.  By default, it permits turning on strictures, warnings,
features, and diagnostics, as well as requiring a minimum Perl
version.

=head1 METHODS

=cut

use Perl::Critic::Utils;
use base qw(Perl::Critic::Policy);

our $VERSION = '0.008';

my $EXPLANATION = 'Violates encapsulation';
my $DESCRIPTION = 'Code (other than strict/warnings) not in explicit package';

sub default_severity { $SEVERITY_HIGH  }
sub default_themes   { qw( risky )     }
sub applies_to       { 'PPI::Document' }

=head2 supported_parameters

The default list of pragmata that are permitted before a C<package>
declaration can be changed via the C<allowed_pragmata> configuration
parameter. Its value is a space-separated list of pragma names to be
permitted.  In this list, the name C<perlversion> is special: it
allows a C<use 5.xxx> statement.

This module understands the C<exempt_scripts> configuration parameter just like
L<Perl::Critic::Policy::Modules::RequireExplicitPackage>.

=cut

sub supported_parameters {
  return (
	   {
	     name => 'allowed_pragmata',
	     description =>
	       'Names of pragmata that are permitted before package declaration',
	     default_string => 'diagnostics feature perlversion strict warnings',
	     behavior => 'string list',
	   },
	   {
	     name => 'exempt_scripts',
	     description => q(Don't require programs to have a package statement.),
	     default_string => '1',
	     behavior => 'boolean',
	   },
	 );
}

sub initialize_if_enabled {
  my($self, $config) = @_;
  # The real parsing was done to spec in supported_parameters, but we
  # convert the list to a hash here for ease of use later.
  $self->{_allowed_pragmata} = { map { {$_ => 1} } @{$self->{_allowed_pragmata}} }
    if ref $self->{_allowed_pragmata} eq 'ARRAY';
  return $TRUE;
}

sub violates {
  my ($self, $elem, $doc) = @_;

  # You can configure this policy to exclude scripts
  return if $self->{_exempt_scripts} && $doc->is_program;

  # Find the first 'package' statement
  my $package_stmnt = $doc->find_first('PPI::Statement::Package');
  my $package_line = $package_stmnt ? $package_stmnt->location()->[0] : undef;

  # Find all statements that aren't 'package' statements
  my $stmnts_ref = $doc->find('PPI::Statement');
  return if !$stmnts_ref;
  my @non_packages =
    grep { not(
      $_->isa('PPI::Statement::Include') && $_->type eq 'use'
      && ( $_->version && exists $self->{_allowed_pragmata}{perlversion} ||
	 exists $self->{_allowed_pragmata}{ $_->module } )
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

Copyright (c) 2006 Ricardo SIGNES and Jeffrey Ryan Thalhammer.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
