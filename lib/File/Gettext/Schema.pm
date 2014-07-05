package File::Gettext::Schema;

use namespace::autoclean;

use Moo;
use File::DataClass::Constants;
use File::DataClass::Types  qw( Directory Str Undef );
use File::Gettext::Constants;
use File::Gettext::ResultSource;
use File::Gettext::Storage;
use Scalar::Util            qw( blessed );
use Type::Utils             qw( as coerce declare from enum via );

extends q(File::DataClass::Schema);

my $LanguageType = declare as Str;

coerce $LanguageType, from Undef, via { LANG };

has 'lang'      => is => 'rw', isa => $LanguageType,
   coerce       => $LanguageType->coercion, default => LANG;

has 'localedir' => is => 'ro', isa => Directory, coerce => Directory->coercion,
   default      => sub { LOCALE_DIRS->[ 0 ] };

around 'BUILDARGS' => sub {
   my ($orig, $class, @args) = @_; my $attr = $orig->( $class, @args );

   $attr->{result_source_class} = 'File::Gettext::ResultSource';

   return $attr;
};

sub BUILD {
   my $self    = shift;
   my $storage = $self->storage;
   my $class   = 'File::Gettext::Storage';
   my $attrs   = { schema => $self, storage => $storage };

   blessed $storage ne $class and $self->storage( $class->new( $attrs ) );

   return;
}

1;

__END__

=pod

=head1 Name

File::Gettext::Schema - Adds language support to the default schema

=head1 Synopsis

=head1 Description

Extends L<File::DataClass::Schema>

=head1 Configuration and Environment

Defines these attributes

=over 3

=item C<lang>

The two character language code, e.g. C<de>.

=item C<localedir>

Path to the subtree containing the MO/PO files

=back

=head1 Subroutines/Methods

=head2 BUILDARGS

Sets the result source class to L<File::Gettext::ResultSource>

=head2 BUILD

If the schema is language dependent then an instance of
L<File::Gettext::Storage> is created as a proxy for the storage class

=head1 Diagnostics

=head1 Dependencies

=over 3

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

Peter Flanigan, C<< <Support at RoxSoft.co.uk> >>

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
