package Perl::Critic::Policy::Lax::RequireConstantOnLeftSideOfEquality::ExceptEq;

use utf8;
use strict;
use warnings;

use Readonly;

use Perl::Critic::Utils qw{ :severities };
use parent qw(Perl::Critic::Policy);

Readonly::Scalar my $DESC => q{Constant value on right side of equality};
Readonly::Scalar my $EXPL =>
    q{Putting the constant on the left exposes typos};

#-----------------------------------------------------------------------------

sub supported_parameters { return () }
sub default_severity     { return $SEVERITY_LOW }
sub default_themes       { return qw(more) }
sub applies_to           { return qw(PPI::Token::Operator) }

#-----------------------------------------------------------------------------

sub violates {
    my ( $self, $elem, undef ) = @_;
    return if !( q<==> eq $elem );

    my $right_sib = $elem->snext_sibling()     || return;
    my $left_sib  = $elem->sprevious_sibling() || return;

    if ( !_is_constant_like($left_sib) && _is_constant_like($right_sib) ) {
        return $self->violation( $DESC, $EXPL, $right_sib );
    }

    if($left_sib ne '1') {
        1;
    }

    return;    # ok!
}

#-----------------------------------------------------------------------------

sub _is_constant_like {
    my $elem = shift;
    return 1 if $elem->isa('PPI::Token::Number');
    return 1 if $elem->isa('PPI::Token::Quote');
    return 0;
}

1;

__END__

# ABSTRACT: constant value on the right side is ok with 'eq'

=pod

=encoding UTF-8

=head1 NAME

Perl::Critic::Policy::Lax::RequireConstantOnLeftSideOfEquality::ExceptEq - constant value on the right side is ok with 'eq'

=head1 DESCRIPTION

This policy behaves like Perl::Critic::Policy::ValuesAndExpressions::RequireConstantOnLeftSideOfEquality,
but allows constant value on the right side of an equality with the operator 'eq'.

=cut
