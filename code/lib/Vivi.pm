package Vivi;
use strict;

use Apache2::RequestRec (); # for $r->content_type
use Apache2::RequestIO ();  # for print
use Apache2::Const -compile => ':common';
use Apache2::Log;
use APR::Table ();
use URI::Escape           qw/uri_unescape/;
use Data::Dumper::Simple;
use File::Spec;
use Cwd                   qw/abs_path/;
use Vivi::Data;
use Template;
use vars qw( $TT );

use constant BASE => "/shared";

sub handler {
   my $r = shift;

   # create or reuse existing Template object
   $TT ||= Template->new({ INCLUDE_PATH  => '/code/templates', });

   my $url_arg   = _uri_clean($r->args());   # /somedir/somefileordir, maybe empty
   my $target    = BASE . $url_arg;          # /shared/somedir/somefileordir
   $r->log_error('Target: ' . $target);
   my $parent_dir = '/';                     # somedir
   my $filename;                             # somefileordir
   if ( $url_arg ) {
      (undef, $parent_dir, $filename) = File::Spec->splitpath( $url_arg );
   } 

   # Its a directory!
   ##################
   if (-d $target) {
     $r->content_type('text/html');
     chdir($target);
   } else {
   # Its a File!
   ##############
     chdir(BASE);
     my $file = Vivi::Data->new($target);
     $file->handle($r);
     return Apache2::Const::OK;
   }

   my $file_list;
   my $dir_list;
   for my $file (glob("*")) {
     if ( -d $file ) {
       $dir_list->{$file}  = { icon => "folder" };
     } else {
       my $file_obj = Vivi::Data->new($file);
       $file_list->{$file} = { icon => $file_obj->icon() || "document-outline" };
     }
   }
   # print encode_json({ data => $file_list });
   $TT->process('list.tt2', { file_list  => $file_list,
                              dir_list   => $dir_list,
                              cwd        => $url_arg,
                              parent_dir => $parent_dir,
                                                       }, $r) || do {
      $r->log_error($TT->error( ));
      return Apache2::Const::SERVER_ERROR;
   };

   return Apache2::Const::OK;
}

sub _uri_clean {
    my $dirty_url = shift;
    my $utf8_url  = uri_unescape($dirty_url); # %20 -> " " 
    $utf8_url     =~ s|/+|/|g;                # //// -> /
    $utf8_url     =~ s|/$||g;                 # sthg/ -> sthg
    $utf8_url     =~ s|/\.\.|/|g;             # /../ -> /
    return $utf8_url;
}

1;

