<div>
    <a href="https://travis-ci.org/pjfl/p5-file-gettext"><img src="https://travis-ci.org/pjfl/p5-file-gettext.svg?branch=master" alt="Travis CI Badge"></a>
    <a href="https://roxsoft.co.uk/coverage/report/file-gettext/latest"><img src="https://roxsoft.co.uk/coverage/badge/file-gettext/latest" alt="Coverage Badge"></a>
    <a href="http://badge.fury.io/pl/File-Gettext"><img src="https://badge.fury.io/pl/File-Gettext.svg" alt="CPAN Badge"></a>
    <a href="http://cpants.cpanauthors.org/dist/File-Gettext"><img src="http://cpants.cpanauthors.org/dist/File-Gettext.png" alt="Kwalitee Badge"></a>
</div>

# Name

File::Gettext - Read and write GNU Gettext po / mo files

# Version

This documents version v0.30.$Rev: 3 $ of [File::Gettext](https://metacpan.org/pod/File::Gettext)

# Synopsis

    use File::Gettext;

    my $domain = File::Gettext->new( $attrs )->load( $lang, @files );

# Description

Extends [File::DataClass::Schema](https://metacpan.org/pod/File::DataClass::Schema). Provides for the reading and
writing of GNU Gettext PO files and the reading of MO files. Used by
[Class::Usul::L10N](https://metacpan.org/pod/Class::Usul::L10N) to translate application message strings into different
languages

# Configuration and Environment

Defines the following attributes;

- `charset`

    Default character set used it the `mo` / `po` does not specify one. Defaults
    to `iso-8859-1`

- `default_po_header`

    Default header information used to create new `po` files

- `gettext_catagory`

    Subdirectory of a language specific subdirectory of ["localdir"](#localdir) that contains
    the `mo` / `po` files. Defaults to `LC_MESSAGES`. Can be set to the null
    string to eliminate from path

- `header_key_table`

    Maps attribute header names onto their `po` file header strings

- `localedir`

    Base path to the `mo` / `po` files

- `result_source_attributes`

    Defines the attributes available in the result object

- `source_name`

    Either `po` or `mo`. Defaults to `po`

# Subroutines/Methods

## `BUILDARGS`

Extracts default attribute values from the `builder` parameter

## `load`

This method modifier adds the pluralisation function to the return data

## `object_file`

    $gettext->object_file( $lang, $file );

Returns the path to the `po` / `mo` file for the specified language

## `resultset`

A method modifier that provides the result source name to the same method
in the parent class

## `set_path`

    $gettext->set_path( $lang, $file );

Sets the _path_ attribute on the parent class from `$lang` and `$file`

## `source`

A method modifier that provides the result source name to the same method
in the parent class

# Diagnostics

None

# Dependencies

- [File::DataClass](https://metacpan.org/pod/File::DataClass)
- [Moo](https://metacpan.org/pod/Moo)

# Incompatibilities

There are no known incompatibilities in this module

# Bugs and Limitations

There are no known bugs in this module.
Please report problems to the address below.
Patches are welcome

# Acknowledgements

Larry Wall - For the Perl programming language

# Author

Peter Flanigan, `<pjfl@cpan.org>`

# License and Copyright

Copyright (c) 2016 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/pod/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
