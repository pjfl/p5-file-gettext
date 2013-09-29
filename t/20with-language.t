# @(#)$Ident: 20with-language.t 2013-06-09 14:04 pjf ;

use strict;
use warnings;
use version; our $VERSION = qv( sprintf '0.21.%d', q$Rev: 1 $ =~ /\d+/gmx );
use File::Spec::Functions;
use FindBin qw( $Bin );
use lib catdir( $Bin, updir, q(lib) );

use Module::Build;
use Test::More;

my $reason;

BEGIN {
   my $builder = eval { Module::Build->current };

   $builder and $reason = $builder->notes->{stop_tests};
   $reason  and $reason =~ m{ \A TESTS: }mx and plan skip_all => $reason;
}

use English qw(-no_match_vars);
use File::DataClass::IO;
use Text::Diff;

sub test ($$$) {
   my ($obj, $method, @args) = @_; local $EVAL_ERROR;

   my $wantarray = wantarray; my $res;

   eval {
      if ($wantarray) { $res = [ $obj->$method( @args ) ] }
      else            { $res =   $obj->$method( @args )   }
   };

   my $e = $EVAL_ERROR; $e and return $e;

   return $wantarray ? @{ $res } : $res;
}

use_ok 'File::Gettext';
use_ok 'File::Gettext::Constants';
use_ok 'File::Gettext::Schema';

my $osname  = lc $OSNAME;
my $ntfs    = $osname eq 'mswin32' || $osname eq 'cygwin' ? 1 : 0;
my $default = catfile( qw(t default.xml) );
my $schema  = File::Gettext::Schema->new
   ( path      => $default,
     lang      => q(en),
     localedir => catdir( qw(t locale) ),
     result_source_attributes => {
        pages => {
           attributes => [ qw(columns heading) ],
           lang       => q(en),
           lang_dep   => { qw(heading 1) }, }, },
     tempdir => q(t) );

isa_ok( $schema, q(File::DataClass::Schema) );

is $schema->lang, q(en), 'Has language attribute';

my $source = $schema->source( q(pages) );

my $rs = $source->resultset; my $args = {};

$args->{name} = q(dummy); $args->{columns} = 3;

$args->{heading} = q(This is a heading);

my $res = test $rs, q(create), $args;

is $res, q(dummy), 'Creates dummy element and inserts';

$args->{columns} = q(2); $args->{heading} = q(This is a heading also);

$res = test $rs, q(update), $args;

is $res, q(dummy), 'Can update';

$ntfs and $schema->path->close; # See if this fixes winshite

delete $args->{columns}; delete $args->{heading};

$res = test $rs, q(find), $args;

is $res->columns, 2, 'Can find';

$ntfs and $schema->path->close; # See if this fixes winshite

my $e = test $rs, q(create), $args;

ok $e =~ m{ already \s+ exists }mx, 'Detects already existing element';

$ntfs and $schema->path->close; # See if this fixes winshite

$res = test $rs, q(delete), $args;

is $res, q(dummy), 'Deletes dummy element';

$e = test $rs, q(delete), $args;

ok $e =~ m{ does \s+ not \s+ exist }mx, 'Detects non existing element';

$schema->lang( q(de) ); $args->{name} = q(dummy);

$args->{columns} = 3; $args->{heading} = q(This is a heading);

$res = test $rs, q(create), $args;

is $res, q(dummy), 'Creates dummy element and inserts 2';

my $data   = $schema->load;
my $dumped = catfile( qw(t dumped.xml)   );
my $pofile = catfile( qw(t locale de LC_MESSAGES dumped.po) );

$schema->dump( { data => $data, path => $dumped } );

my $gettext = File::Gettext->new( path => $pofile, tempdir => q(t) );

$data = $gettext->load;

my $key  = 'pages.heading'.CONTEXT_SEP().'dummy';
my $text = $data->{ 'po' }->{ $key }->{ 'msgstr' }->[ 0 ];

ok $text eq 'This is a heading', 'Dumps';

$res = test $rs, q(delete), $args;

is $res, q(dummy), 'Deletes dummy element 2';

done_testing;

# Cleanup

io( $dumped )->unlink;
io( $pofile )->unlink;
io( catfile( qw(t locale de LC_MESSAGES default.po)  ) )->unlink;
io( catfile( qw(t locale en LC_MESSAGES default.po)  ) )->unlink;
io( catfile( qw(t ipc_srlock.lck) ) )->unlink;
io( catfile( qw(t ipc_srlock.shm) ) )->unlink;
io( catfile( qw(t file-dataclass-schema.dat) ) )->unlink;

# Local Variables:
# mode: perl
# tab-width: 3
# End:
