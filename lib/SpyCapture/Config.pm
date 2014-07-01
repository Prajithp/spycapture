package	SpyCapture::Config;

use strict;

sub new {
  my ($class, %args) = @_;
  
  my $self = { %args };
  $self->{config} = $ENV{'SPY_CAPTURE_CONF'} || '/usr/local/spycapture/etc/spycapture.conf';
  bless($self, $class);
 
  return $self;
}

sub init {
  my $self = shift;
  
  my $config = $self->load();
  
  $config->{delay_time} = '180' unless($config->{delay_time});
  $config->{storage_type} = 'local' unless($config->{storage_type});
  $config->{log_file}  = '/var/log/spycapture.log' unless($config->{log_file});
  
  return $config;
}


sub load {
  my $self = shift;
  my $file = $self->{config};
  
  my %ret;
  if (open( my $fh, '<', $file )) {
    while ( my $line = readline($fh) ) {
      chomp $line;
      next if $line =~ /^\s*#/;
      next unless $line =~ /^(\S+)=(\S+)$/;
      $ret{$1} = $2;
    }
    close $fh;
  }
  else {
    die "unable to open config file $file";
  }
  return \%ret;
}

1;
