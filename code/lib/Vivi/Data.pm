package Vivi::Data;
use strict;
use warnings;
use MIME::Type::FileName;

sub new {
    my ($class, $filename) = @_;
    return bless { filename => $filename }, $class;
}

# Ver los iconos en https://ionicons.com/
sub icon {
    my ($self) = @_;
    my $mimetype = MIME::Type::FileName::guess($self->{'filename'});
      return "videocam-outline"      if ($mimetype =~ /video/);
      return "camera-outline"        if ($mimetype =~ /image/);
      return "musical-notes-outline" if ($mimetype =~ /audio/);
      return "document-outline";
}

sub force_download {
    my ($self, $force_download) = @_;
    $self->{'force_download'} = $force_download;
}

sub handle {
    my ($self, $r) = @_;


    if ($self->{'force_download'}) {
      # Get the filename (no dir name)
      my (undef, undef, $filename) = File::Spec->splitpath( $self->{'filename'} );

      # Force filename through custom headers
      $r->content_type('application/octet-stream');
      $r->headers_out->set('Content-Disposition', qq/attachment; filename="$filename"/);
    } else {
      # Mime type (for header)
      my $mimetype = MIME::Type::FileName::guess($self->{'filename'});

      # Send headers
      $r->content_type($mimetype);
    }

    # Open and print the file
    open my $fh, '<', $self->{'filename'} or die "open failed: $!";
    binmode($fh) or die "binmode failed: $!";
 
    while (1) {
      my $chunk = '';
      my $success = read $fh, $chunk, 1024 * 1024;
      die $! if not defined $success;
      print $chunk;
      last if not $success;
    }
    close($fh);
}

1;
