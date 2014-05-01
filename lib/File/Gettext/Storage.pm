# @(#)$Ident: Storage.pm 2014-01-30 00:00 pjf ;

package File::Gettext::Storage;

use namespace::sweep;
use version; our $VERSION = qv( sprintf '0.22.%d', q$Rev: 2 $ =~ /\d+/gmx );

use Moo;
use File::Basename             qw( basename );
use File::DataClass::Constants;
use File::DataClass::Functions qw( is_stale merge_file_data throw );
use File::DataClass::Types     qw( Object );
use File::Gettext;
use Try::Tiny;
use Unexpected::Functions      qw( NothingUpdated Unspecified );

has 'gettext' => is => 'lazy', isa => Object, builder => sub {
   File::Gettext->new( builder     => $_[ 0 ]->schema,
                       cache_class => $_[ 0 ]->cache_class,
                       localedir   => $_[ 0 ]->localedir );
};

has 'schema'  => is => 'ro',   isa => Object,  required => TRUE,
   handles    => [ qw( cache cache_class lang localedir ) ], weak_ref => TRUE;

has 'storage' => is => 'ro',   isa => Object,  required => TRUE,
   handles    => [ qw( extn meta_pack meta_unpack
                       read_file txn_do validate_params ) ];

# Public methods
sub delete {
   my ($self, $path, $result) = @_;

   my $source    = $result->_resultset->source;
   my $condition = sub { $source->lang_dep->{ $_[ 0 ] } };
   my $deleted   = $self->storage->delete( $path, $result );
   my $rs        = $self->_gettext( $path )->resultset;
   my $element   = $source->name;

   for my $attr_name (__get_attributes( $condition, $source )) {
      my $attrs  = { msgctxt => "${element}.${attr_name}",
                     msgid   => $result->name, };
      my $name   = $rs->storage->make_key( $attrs );

      $name      = $rs->delete( { name => $name, optional => TRUE } );
      $deleted ||= $name ? TRUE : FALSE;
   }

   return $deleted;
}

sub dump {
   my ($self, $path, $data) = @_; $self->validate_params( $path, TRUE );

   my $gettext      = $self->_gettext( $path );
   my $gettext_data = $gettext->path->is_file ? $gettext->load : {};

   for my $source (values %{ $self->schema->source_registrations }) {
      my $element = $source->name; my $element_ref = $data->{ $element };

      for my $msgid (keys %{ $element_ref }) {
         for my $attr_name (keys %{ $source->lang_dep || {} }) {
            my $msgstr = delete $element_ref->{ $msgid }->{ $attr_name }
                      or next;
            my $attrs  = { msgctxt => "${element}.${attr_name}",
                           msgid   => $msgid,
                           msgstr  => [ $msgstr ] };
            my $key    = $gettext->storage->make_key( $attrs );

            $gettext_data->{ $gettext->source_name }->{ $key } = $attrs;
         }
      }
   }

   $gettext->dump( { data => $gettext_data } );

   return $self->storage->dump( $path, $data );
}

sub insert {
   return $_[ 0 ]->_create_or_update( $_[ 1 ], $_[ 2 ], FALSE );
}

sub load {
   my ($self, @paths) = @_; $paths[ 0 ] or return {};

   my ($key, $newest) = $self->_get_key_and_newest( \@paths );
   my ($data, $meta)  = $self->cache->get( $key );
   my $cache_mtime    = $self->meta_unpack( $meta );

   not is_stale $data, $cache_mtime, $newest and return $data;

   $data = {}; $newest = 0;

   for my $path (@paths) {
      my ($red, $path_mtime) = $self->read_file( $path, FALSE );

      merge_file_data $data, $red;
      $path_mtime > $newest and $newest = $path_mtime;
      $path_mtime = $self->_load_gettext( $data, $path );
      $path_mtime and $path_mtime > $newest and $newest = $path_mtime;
   }

   $self->cache->set( $key, $data, $self->meta_pack( $newest ) );

   return $data;
}

sub select {
   my ($self, $path, $element) = @_; $self->validate_params( $path, $element );

   my $data = $self->load( $path );

   return exists $data->{ $element } ? $data->{ $element } : {};
}

sub update {
   return $_[ 0 ]->_create_or_update( $_[ 1 ], $_[ 2 ], TRUE );
}

# Private methods
sub _create_or_update {
   my ($self, $path, $result, $updating) = @_;

   my $source    = $result->_resultset->source;
   my $condition = sub { not $source->lang_dep->{ $_[ 0 ] } };
   my $updated   = $self->storage->create_or_update
      ( $path, $result, $updating, $condition );
   my $rs        = $self->_gettext( $path )->resultset;
   my $element   = $source->name;

   $condition = sub { $source->lang_dep->{ $_[ 0 ] } };

   for my $attr_name (__get_attributes( $condition, $source )) {
      my $msgstr = $result->$attr_name() or next;
      my $attrs  = { msgctxt => "${element}.${attr_name}",
                     msgid   => $result->name,
                     msgstr  => [ $msgstr ], };

      $attrs->{name} = $rs->storage->make_key( $attrs ); my $name;

      try {
         $name = $updating ? $rs->create_or_update( $attrs )
                           : $rs->create( $attrs );
      }
      catch { $_->class ne NothingUpdated and throw $_ };

      $updated ||= $name ? TRUE : FALSE;
   }

   $updating and not $updated and throw class => NothingUpdated, level => 4;
   $updated  and $path->touch;
   return $updated;
}

sub _extn {
   my $extn = (split m{ \. }mx, ($_[ 1 ] || NUL))[ -1 ];

   return $extn ? ".${extn}" : $_[ 0 ]->extn;
}

sub _get_key_and_newest {
   my ($self, $paths) = @_; my $key; my $newest = 0; my $valid = TRUE;

   for my $path (grep { length } map { "${_}" } @{ $paths }) {
      $key .= $key ? "~${path}" : $path;

      my $mtime = $self->cache->get_mtime( $path );

      if ($mtime) { $mtime > $newest and $newest = $mtime }
      else { $valid = FALSE }

      my $file      = basename( "${path}", $self->_extn( $path ) );
      my $lang_path = $self->gettext->get_path( $self->lang, $file );

      if (defined ($mtime = $self->cache->get_mtime( "${lang_path}" ))) {
         if ($mtime) {
            $key .= $key ? "~${lang_path}" : $lang_path;
            $mtime > $newest and $newest = $mtime;
         }
      }
      else {
         if (-f $lang_path) {
            $key .= $key ? "~${lang_path}" : $lang_path; $valid = FALSE;
         }
         else { $self->cache->set_mtime( "${lang_path}", 0 ) }
      }
   }

   return ($key, $valid ? $newest : undef);
}

sub _gettext {
   my ($self, $path) = @_; my $gettext = $self->gettext;

   $path or throw class => Unspecified, args => [ 'path name' ];

   my $extn = $self->_extn( $path );

   $gettext->set_path( $self->lang, basename( "${path}", $extn ) );

   return $gettext;
}

sub _load_gettext {
   my ($self, $data, $path) = @_;

   my $gettext = $self->_gettext( $path ); $gettext->path->is_file or return;

   my $gettext_data = $gettext->load->{ $gettext->source_name };

   for my $key (keys %{ $gettext_data }) {
      my ($msgctxt, $msgid)     = $gettext->storage->decompose_key( $key );
      my ($element, $attr_name) = split m{ [\.] }msx, $msgctxt, 2;

      ($element and $attr_name and $msgid) or next;

      $data->{ $element }->{ $msgid }->{ $attr_name }
         = $gettext_data->{ $key }->{msgstr}->[ 0 ];
   }

   return $gettext->path->stat->{mtime};
}

# Private functions
sub __get_attributes {
   my ($condition, $source) = @_;

   return grep { not m{ \A _ }msx
                 and $_ ne 'name'
                 and $condition->( $_ ) } @{ $source->attributes || [] };
}

1;

__END__

=pod

=head1 Name

File::Gettext::Storage - Split/merge language dependent data

=head1 Version

This document describes v0.22.$Rev: 2 $ of L<File::Gettext::Storage>

=head1 Synopsis

=head1 Description

This is a proxy for the storage class. In general, for each call made to a
storage method this class makes two instead. The "second" call handles
attributes stored in the language dependent file

=head1 Configuration and Environment

Defines the attributes

=over 3

=item C<lang>

Two character language code

=item C<schema>

A weakened reference to the schema object

=item C<storage>

Instance of L<File::DataClass::Storage>

=back

=head1 Subroutines/Methods

=head2 delete

   $bool = $self->delete( $path, $result );

Deletes the specified element object returning true if successful. Throws
an error otherwise

=head2 dump

   $data = $self->dump( $path, $data );

Exposes L<File::DataClass::Storage/dump> in the storage class

=head2 insert

   $bool = $self->insert( $path, $result );

Inserts the specified element object returning true if successful. Throws
an error otherwise

=head2 load

   $data = $self->load( $path );

Exposes L<File::DataClass::Storage/load> in the storage class

=head2 select

   $hash_ref = $self->select( $element );

Returns a hash ref containing all the elements of the type specified in the
result source

=head2 update

   $bool = $self->update( $path, $result );

Updates the specified element object returning true if successful. Throws
an error otherwise

=head1 Diagnostics

None

=head1 Dependencies

=over 3

=item L<File::Gettext>

=back

=head1 Incompatibilities

There are no known incompatibilities in this module

=head1 Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

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
