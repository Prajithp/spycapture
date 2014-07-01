package SpyCapture::Utils;

use strict;
use IPC::Open3;
use Data::Dumper;

sub get_logined_users {
  my ($childin, $childout);
  
  my $pid = IPC::Open3::open3($childin, $childout, $childout, "who -u");
  my @output = <$childout>;
  waitpid ($pid, 0);
  
  my %seen;
  my @users;
  foreach my $line (@output) {
    if ($line =~ m{([a-zA-Z0-9]+)\s+(.+)\s+\((.+)\)}i) {
      next if($seen{$1}); 
      next if($1 eq 'root');
      $seen{$1} = '1';
      push(@users, $1);
    }
  }
  return @users;
}

sub set_user_env {
  my $username = shift;
  return '' unless($username);

  my $pgrep = "/usr/bin/pgrep";
  
  # we don't need these ENV's
  delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};
  
  $ENV{"LANG"} = "C";

  # find DBUS address (sometimes needed), DISPLAY and XAUTHORITY
  if ( -x $pgrep ) {
    my @pids = `pgrep -u $username -f 'gnome-session|kdeinit4|xsession|enlightenment_start|xinitrc'`;
    chomp(@pids);	
    PID: 
      foreach my $pid ( @pids ) {
	if ( -r  "/proc/$pid/environ" ) {
	  local $/ = "\000";
	  if ( open(ENVF, "/proc/$pid/environ") ) {
	    while ( <ENVF> ) {
	      chomp();
	      if ( /^DBUS_SESSION_BUS_ADDRESS=(.*)/ ) {
		$ENV{'DBUS_SESSION_BUS_ADDRESS'} = $1;
	      }
	      if ( /^DISPLAY=(.*)/ ) {
		$ENV{'DISPLAY'} = $1;
	      }
	      if ( /^XAUTHORITY=(.*)/ ) {
		$ENV{'XAUTHORITY'} = $1;
	      }
	    }
	    close(ENVF);
	  }
	}
	last PID if ($ENV{DBUS_SESSION_BUS_ADDRESS} && $ENV{DISPLAY} && $ENV{XAUTHORITY});
      }
  }  
  # Find DISPLAY, for non gnome/kde users:
  unless ($ENV{'DISPLAY'} && $ENV{'XAUTHORITY'}) {
    my ($childin, $childout);
    my $pid = IPC::Open3::open3($childin, $childout, $childout, "who -u");
    my @output = <$childout>;
    waitpid ($pid, 0);
    foreach my $line (@output) {
      if ($line =~ m{([a-zA-Z0-9]+)\s+(.+)\s+\((.+)\)}i) {
	$ENV{'DISPLAY'} = $3 if($1 eq $username && defined($3));
	my @user_info   = getpwnam($username);
	$ENV{'XAUTHORITY'} = $user_info[7] . '/.Xauthority' if ( -e $user_info[7] . '/.Xauthority');
	last;
      }
    }   
  }
  return 1;
}

1;
