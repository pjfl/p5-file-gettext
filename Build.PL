use strict;
use warnings;

use Module::Build 0.4004;

sub testing { $ENV{AUTOMATED_TESTING} || $ENV{PERL_CPAN_REPORTER_CONFIG}
                                      || $ENV{PERL5_CPANPLUS_IS_VERSION} }
sub whimper { print {*STDOUT} $_[ 0 ]."\n"; exit 0 }

my $perl_ver = 5.010001;
my $name     = 'File-Gettext'; $name =~ s{ - }{::}gmx;
my $prereqs  = {
  'build_requires' => {
    'Module::Build' => '0.4004',
    'Test::Requires' => '0.06',
    'Text::Diff' => '1.37',
    'version' => '0.88'
  },
  'configure_requires' => {
    'Module::Build' => '0.4004',
    'version' => '0.88'
  },
  'requires' => {
    'Class::Method::ModifiersX::Augment' => '0.001',
    'Date::Format' => '2.22',
    'Encode' => '2.12',
    'File::DataClass' => 'v0.45.0',
    'Moo' => '1.006000',
    'Try::Tiny' => '0.22',
    'Type::Tiny' => '1.000002',
    'Unexpected' => 'v0.30.0',
    'namespace::autoclean' => '0.19',
    'perl' => '5.010001'
  },
};

if ($] < $perl_ver) { # Not interested in reports below min perl ver
   testing or whimper "Minimum required Perl version is ${perl_ver}";
   $prereqs->{build_requires} = { %{ $prereqs->{configure_requires} } };
   $prereqs->{build_requires}->{ 'Test::Requires' } = 0.06;
   delete $prereqs->{requires};
}

Module::Build->new(
   'module_name' => $name,
   'notes'       => { min_perl_version => $perl_ver },
   %{ $prereqs },

)->create_build_script;

exit 0;
