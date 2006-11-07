use strict;
use warnings;

use inc::Module::Install;

name          ('Perl-Critic-Lax');
author        ('Ricardo SIGNES <rjbs@cpan.org>');
license       ('perl');
version_from
  'lib/Perl/Critic/Policy/Lax/ProhibitStringyEval/ExceptForRequire.pm';

requires('Perl::Critic'     => 0.21);

WriteAll();
