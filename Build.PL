# @(#)$Ident: Build.PL 2013-04-14 15:29 pjf ;

use strict;
use warnings;
use inc::Bob; # Module::Build subclass
use version; our $VERSION = qv( sprintf '0.16.%d', q$Rev: 5 $ =~ /\d+/gmx );

Bob->new( {
   module    => q(File::Gettext),
   home_page => q(http://www.roxsoft.co.uk),
   requires  => {
      'perl'                 => 5.010,
      'namespace::autoclean' => 0.13,
      'version'              => 0.77,
      'Date::Format'         => 2.22,
      'Encode'               => 2.12,
      'File::DataClass'      => q(0.16.0),
      'Moose'                => 2.0801,
   },
   recommends            => {
      'App::cpanminus'   => 1.6005,
      'Date::Format'     => 2.24,
      'Pod::Markdown'    => 1.322,
      'Module::Metadata' => 1.000011, },
   configure_requires    => {
      'version'          => 0.77,
      'Module::Build'    => 0.38, },
   build_requires        => {
      'utf8'             => 1.06,
      'Exception::Class' => 1.23,
      'Test::More'       => 0.74,
      'Text::Diff'       => 1.37, },
} )->create_build_script; # Goal!

# Local Variables:
# eval: (load-project-state "file-gettext")
# mode: perl
# tab-title: File::Gettext
# tab-width: 3
# End:
