package File::Gettext;

use 5.010001;
use namespace::autoclean;
use version; our $VERSION = qv( sprintf '0.26.%d', q$Rev: 2 $ =~ /\d+/gmx );

use Moo;
use English                    qw( -no_match_vars );
use File::DataClass::Constants;
use File::DataClass::Functions qw( throw );
use File::DataClass::IO;
use File::DataClass::Types     qw( ArrayRef Directory HashRef Str Undef );
use File::Gettext::Constants;
use File::Spec::Functions      qw( catfile tmpdir );
use Type::Utils                qw( as coerce declare from enum via );

extends q(File::DataClass::Schema);

my $LocaleDir  = declare as Directory;
my $SourceType = enum 'SourceType' => [ qw(mo po) ];

coerce $LocaleDir,
   from ArrayRef, via { __build_localedir( $_ ) },
   from Str,      via { __build_localedir( $_ ) },
   from Undef,    via { __build_localedir( $_ ) };

# Public attributes
has 'catagory_name'     => is => 'ro', isa => Str, default => 'LC_MESSAGES';

has 'charset'           => is => 'ro', isa => Str, default => 'iso-8859-1';

has 'default_po_header' => is => 'ro', isa => HashRef,
   default              => sub { {
      appname           => 'Your_Application',
      company           => 'ExampleCom',
      email             => '<translators@example.com>',
      lang              => 'en',
      team              => 'Translators',
      translator        => 'Athena', } };

has 'header_key_table'  => is => 'ro', isa => HashRef,
   default              => sub { {
      project_id_version        => [ 0,  q(Project-Id-Version)        ],
      report_msgid_bugs_to      => [ 1,  q(Report-Msgid-Bugs-To)      ],
      pot_creation_date         => [ 2,  q(POT-Creation-Date)         ],
      po_revision_date          => [ 3,  q(PO-Revision-Date)          ],
      last_translator           => [ 4,  q(Last-Translator)           ],
      language_team             => [ 5,  q(Language-Team)             ],
      language                  => [ 6,  q(Language)                  ],
      mime_version              => [ 7,  q(MIME-Version)              ],
      content_type              => [ 8,  q(Content-Type)              ],
      content_transfer_encoding => [ 9,  q(Content-Transfer-Encoding) ],
      plural_forms              => [ 10, q(Plural-Forms)              ], } };

has 'localedir'      => is => 'ro', isa => $LocaleDir,
   coerce            => $LocaleDir->coercion, default => NUL;

has '+result_source_attributes' =>
   default           => sub { {
      mo             => {
         attributes  => [ qw(msgid_plural msgstr) ],
         defaults    => { msgstr => [], }, },
      po             => {
         attributes  =>
            [ qw(translator_comment extracted_comment reference flags
                 previous msgctxt msgid msgid_plural msgstr) ],
         defaults    => { 'flags' => [], 'msgstr' => [], },
         label_attr  => q(labels),
      }, } };

has '+storage_class' => default => q(+File::Gettext::Storage::PO);

has 'source_name'    => is => 'ro', isa => $SourceType,
   default           => q(po), trigger => TRUE;

# Construction
around 'source' => sub {
   my ($orig, $self) = @_; return $orig->( $self, $self->source_name );
};

around 'resultset' => sub {
   my ($orig, $self) = @_; return $orig->( $self, $self->source_name );
};

around 'load' => sub {
   my ($orig, $self, $lang, @names) = @_;

   my @paths     = grep { $self->_is_file_or_log_debug( $_ ) }
                   map  { $self->_get_path_io( $lang, $_ ) } @names;
   my $data      = $orig->( $self, @paths );
   my $po_header = exists $data->{po_header}
                 ? $data->{po_header}->{msgstr} || {} : {};
   my $plural_func;

   # This is here because of the code ref. Cannot serialize (cache) a code ref
   # Determine plural rules. The leading and trailing space is necessary
   # to be able to match against word boundaries.
   if (exists $po_header->{plural_forms}) {
      my $code = SPC.$po_header->{plural_forms}.SPC;

      $code =~ s{ ([^_a-zA-Z0-9] | \A) ([_a-z][_A-Za-z0-9]*)
                     ([^_a-zA-Z0-9]) }{$1\$$2$3}gmsx;
      $code = "sub { my \$n = shift; my (\$plural, \$nplurals);
                     $code;
                     return (\$nplurals, \$plural ? \$plural : 0); }";

      # Now try to evaluate the code. There is no need to run the code in
      # a Safe compartment. The above substitutions should have destroyed
      # all evil code. Corrections are welcome!
      $plural_func = eval $code; ## no critic
      $EVAL_ERROR and $plural_func = undef;
   }

   # Default is Germanic plural (which is incorrect for French).
   $data->{plural_func} = $plural_func || sub { (2, shift > 1) };

   return $data;
};

# Public methods
sub get_path {
   my ($self, $lang, $file) = @_; my $extn = $self->storage->extn;

   $lang or throw 'Language not specified';
   $file or throw 'Language file path not specified';

   return catfile( $self->localedir, $lang, $self->catagory_name, $file.$extn );
}

sub set_path {
   my ($self, @rest) = @_; return $self->path( $self->_get_path_io( @rest ) );
}

# Private methods
sub _get_path_io {
   return io( $_[ 0 ]->get_path( $_[ 1 ], $_[ 2 ] ) );
}

sub _is_file_or_log_debug {
   my ($self, $path) = @_; $path->is_file and return TRUE;

   $self->log->debug( 'Path '.$path->pathname.' not found' );

   return FALSE;
}

sub _trigger_source_name {
   my ($self, $source) = @_;

   $source eq 'mo' and $self->storage_class( '+File::Gettext::Storage::MO' );

   return;
}

# Private functions
sub __build_localedir {
   my $dir = shift; my $io;

   $dir and $io = io( $dir ) and $io->is_dir and return $io;

   for $dir (map { io( $_ ) } @{ LOCALE_DIRS() }) {
      $dir->is_dir and return $dir;
   }

   return io( tmpdir() );
}

1;

__END__

=pod

=begin markdown

[![Build Status](https://travis-ci.org/pjfl/p5-file-gettext.svg?branch=master)](https://travis-ci.org/pjfl/p5-file-gettext)
[![CPAN version](https://badge.fury.io/pl/File-Gettext.svg)](http://badge.fury.io/pl/File-Gettext)

=end markdown

=head1 Name

File::Gettext - Read and write GNU gettext po/mo files

=head1 Version

This documents version v0.26.$Rev: 2 $ of L<File::Gettext>

=head1 Synopsis

   use File::Gettext;

   my $domain = File::Gettext->new( $attrs )->load( $lang, @names );

=head1 Description

Extends L<File::DataClass::Schema>. Provides for the reading and
writing of GNU Gettext PO files and the reading of MO files. Used by
L<Class::Usul::L10N> to translate application message strings into different
languages

=head1 Configuration and Environment

Defines the following attributes;

=over 3

=item C<catagory_name>

Subdirectory of C<localdir> that contains the F<mo> / F<po> files. Defaults
to C<LC_MESSAGES>

=item C<charset>

Default character set used it the F<mo> / F<po> does not specify one. Defaults
to C<iso-8859-1>

=item C<default_po_header>

Default header information used to create new F<po> files

=item C<header_key_table>

Maps attribute header names onto their F<po> file header strings

=item C<localedir>

Base path to the F<mo> / F<po> files

=item C<result_source_attributes>

Defines the attributes available in the result object

=item C<source_name>

Either F<po> or F<mo>. Defaults to F<po>

=back

=head1 Subroutines/Methods

=head2 get_path

   $gettext->get_path( $lang, $file );

Returns the path to the po/mo file for the specified language

=head2 load

This method modifier adds the pluralisation function to the return data

=head2 resultset

A method modifier that provides the result source name to the same method
in the parent class

=head2 set_path

   $gettext->set_path( $lang, $file );

Sets the I<path> attribute on the parent class from C<$lang> and C<$file>

=head2 source

A method modifier that provides the result source name to the same method
in the parent class

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<File::DataClass>

=item L<Moo>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

=head1 Acknowledgements

Larry Wall - For the Perl programming language

=head1 Author

Peter Flanigan, C<< <pjfl@cpan.org> >>

=head1 License and Copyright

Copyright (c) 2014 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE

=cut

# Local Variables:
# mode: perl
# tab-width: 3
# End:
