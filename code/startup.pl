use lib qw(/code/lib/);
use Apache2::ServerUtil;
use Apache2::Log;
use Apache2::Const -compile => qw(OK :log);
use APR::Const     -compile => qw(:error SUCCESS);

my $s = Apache2::ServerUtil->server;
$s->log_error("server: log_error starting...");
1;

