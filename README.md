# Name

File::Gettext - Read and write GNU gettext po/mo files

# Version

This documents version v0.16.$Rev: 4 $ of [File::Gettext](https://metacpan.org/module/File::Gettext)

# Synopsis

    use File::Gettext;

# Description

# Subroutines/Methods

## get\_path

    $gettext->get_path( $lang, $file );

Returns the path to the po/mo file for the specified language

## set\_path

    $gettext->set_path( $lang, $file );

Sets the _path_ attribute on the parent class from `$lang` and `$file`

# Configuration and Environment

# Diagnostics

# Dependencies

- [Moose](https://metacpan.org/module/Moose)

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
