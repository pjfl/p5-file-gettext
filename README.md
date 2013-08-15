# Name

File::Gettext - Read and write GNU gettext po/mo files

# Version

This documents version v0.20.$Rev: 0 $ of [File::Gettext](https://metacpan.org/module/File::Gettext)

# Synopsis

    use File::Gettext;

    my $domain = File::Gettext->new( $attrs )->load( $lang, @names );

# Description

Extends [File::DataClass::Schema](https://metacpan.org/module/File::DataClass::Schema). Provides for the reading and
writing of GNU Gettext PO files and the reading of MO files. Used by
[Class::Usul::L10N](https://metacpan.org/module/Class::Usul::L10N) to translate application message strings into different
languages

# Configuration and Environment

Defines the following attributes;

- `catagory_name`

    Subdirectory of `localdir` that contains the `mo` / `po` files. Defaults
    to `LC_MESSAGES`

- `charset`

    Default character set used it the `mo` / `po` does not specify one. Defaults
    to `iso-8859-1`

- `default_po_header`

    Default header information used to create new `po` files

- `header_key_table`

    Maps attribute header names onto their `po` file header strings

- `localedir`

    Base path to the `mo` / `po` files

- `result_source_attributes`

    Defines the attributes available in the result object

- `source_name`

    Either `po` or `mo`. Defaults to `po`

# Subroutines/Methods

## get\_path

    $gettext->get_path( $lang, $file );

Returns the path to the po/mo file for the specified language

## load

This method modifier adds the pluralization function to the return data

## resultset

A method modifier that provides the result source name to the same method
in the parent class

## set\_path

    $gettext->set_path( $lang, $file );

Sets the _path_ attribute on the parent class from `$lang` and `$file`

## source

A method modifier that provides the result source name to the same method
in the parent class

# Diagnostics

None

# Dependencies

- [File::DataClass](https://metacpan.org/module/File::DataClass)
- [Moo](https://metacpan.org/module/Moo)

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

Copyright (c) 2013 Peter Flanigan. All rights reserved

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See [perlartistic](https://metacpan.org/module/perlartistic)

This program is distributed in the hope that it will be useful,
but WITHOUT WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE
