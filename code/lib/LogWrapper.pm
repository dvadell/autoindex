package LogWrapper;
use strict;
use warnings;
use feature 'say';
use Apache2::ServerUtil;
use Apache2::Log;
use Apache2::Const -compile => qw(OK :log);
use APR::Const    -compile => qw(:error SUCCESS);


use Vivi;

sub handler {
  my $return_value;
  my $r = shift;
  my $s = Apache2::ServerUtil->server;
  eval {
    $return_value = Vivi::handler($r)
  };
  if ($@) {
    $s->log_error($@);
    $return_value = $@;
  }
  return $return_value;
}
1;

