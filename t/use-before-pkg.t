
use strict;
use warnings;

use Perl::Critic::TestUtils qw(pcritique);
use Test::More;

my @ok = (
  q{
use strict; use warnings;
package Whatever;
},
  q{#!/usr/bin/perl
use strict 'refs';
package Thinger;
my $x = 1;
},
  q{
use strict;
use warnings 'once';
package Foo;
our $x = 10;
},
);

my @not_ok = (
  q{
use strict;
use Carp;
package Yourface;
carp "Hello!";
},
  q{
$x = 10; use strict;
package Thinger;
},
);

plan tests => @ok + @not_ok;

my $policy = 'Lax::RequireExplicitPackage::ExceptForPragmata';

for my $i (0 .. $#ok) {
  my $violation_count = pcritique($policy, \$ok[$i]);
  is($violation_count, 0, "nothing wrong with \@ok[$i]");
}

for my $i (0 .. $#not_ok) {
  my $violation_count = pcritique($policy, \$not_ok[$i]);
  is($violation_count, 1, "\@not_ok[$i] is no good");
}
