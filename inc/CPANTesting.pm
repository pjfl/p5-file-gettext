# @(#)Ident: CPANTesting.pm 2013-08-04 08:39 pjf ;

package CPANTesting;

use strict;
use warnings;

use Sys::Hostname; my $host = lc hostname; my $osname = lc $^O;

# Is this an attempted install on a CPAN testing platform?
sub is_testing { !! ($ENV{AUTOMATED_TESTING} || $ENV{PERL_CR_SMOKER_CURRENT}
                 || ($ENV{PERL5OPT} || q()) =~ m{ CPAN-Reporter }mx) }

sub should_abort {
   is_testing() or return 0;

   $host eq q(xphvmfred) and return
      "ABORT: ${host} - cc06993e-a5e9-11e2-83b7-87183f85d660";
   $host =~ m{ nigelhorne }mx
      and return "ABORT: 52e56e36-f9f4-11e2-90a1-fb47fbca4e08";
   return 0;
}

sub test_exceptions {
   my $p = shift; my $perl_ver = $p->{_min_perl_ver} || $p->{requires}->{perl};

   is_testing()        or  return 0;
   $] < $perl_ver      and return "TESTS: Perl minimum ${perl_ver}";
   $p->{stop_tests}    and return 'TESTS: CPAN Testing stopped in Build.PL';
   $osname eq 'mirbsd' and return 'TESTS: Mirbsd OS unsupported';
   $host eq 'vmrz0046' and return 'TESTS: abcbe97a-f9b9-11e2-ae15-23709ec022a8';
   return 0;
}

1;

__END__
