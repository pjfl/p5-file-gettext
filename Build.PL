# @(#)$Ident: Build.PL 2013-07-28 17:58 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.18.%d', q$Rev: 4 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(File::Gettext),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'                       => 5.01,
      'namespace::sweep'           => 0.006,
      'Class::Method::ModifiersX::Augment' => 0.001,
      'Date::Format'               => 2.22,
      'Encode'                     => 2.12,
      'File::DataClass'            => q(0.22.0),
      'Moo'                        => 1.002,
      'Try::Tiny'                  => 0.09,
      'Type::Tiny'                 => 0.008,
   },
   recommends           => {
      'App::cpanminus'  => 1.6005, },
   configure_requires   => {
      'version'         => 0.88,
      'Module::Build'   => 0.4004, },
   build_requires       => {
      'version'         => 0.88,
      'File::DataClass' => q(0.22.0),
      'Module::Build'   => 0.4004,
      'Text::Diff'      => 1.37, },
} )->create_build_script; # Goal!

# Local Variables:
# eval: (load-project-state "file-gettext")
# mode: perl
# tab-title: File::Gettext
# tab-width: 3
# End:
