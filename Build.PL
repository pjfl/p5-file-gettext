# @(#)$Ident: Build.PL 2013-06-09 14:02 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.17.%d', q$Rev: 1 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(File::Gettext),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'                       => 5.01,
      'namespace::autoclean'       => 0.13,
      'Date::Format'               => 2.22,
      'Encode'                     => 2.12,
      'File::DataClass'            => q(0.20.0),
      'Moose'                      => 2.0801,
      'MooseX::Types'              => 0.35,
      'Sub::Exporter::Progressive' => 0.001006,
      'Try::Tiny'                  => 0.09,
   },
   recommends           => {
      'App::cpanminus'  => 1.6005, },
   configure_requires   => {
      'version'         => 0.88,
      'Module::Build'   => 0.4004, },
   build_requires       => {
      'version'         => 0.88,
      'File::DataClass' => q(0.20.0),
      'Module::Build'   => 0.4004,
      'Text::Diff'      => 1.37, },
} )->create_build_script; # Goal!

# Local Variables:
# eval: (load-project-state "file-gettext")
# mode: perl
# tab-title: File::Gettext
# tab-width: 3
# End:
