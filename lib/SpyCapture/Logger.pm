package SpyCapture::Logger;

use strict;

use SpyCapture::Config	();

sub new{
  my ($class, %args) = @_;
  
  my $self = { %args };
  bless($self,$class);
  
  my $config = SpyCapture::Config->new()->init();
  
  $self->{filename} =  $ENV{SPY_CAPTURE_LOG} || $config->{log_file};
  return $self;
}


sub error {
  my ($self, $str) = @_;
  
  my %log = (
        'message' => $str,
        'level'   => 'Error',
  );
  $self->logger( \%log );
}

sub info {
  my ($self, $str) = @_;
  
  my %log = (
        'message' => $str,
        'level'   => 'Info',
  );
  $self->logger( \%log );
}

sub warn {
  my ($self, $str) = @_;
  
  my %log = (
        'message' => $str,
        'level'   => 'Warning',
  );
  $self->logger( \%log );
}

sub _write {
    syswrite( $_[0], $_[1] );
}


sub logger {
  my ( $self, $msg ) = @_;
  
  my $hr = ref($msg) eq 'HASH' ? $msg : { 'message' => $msg };
  
  # default values
  $hr->{'message'} ||= 'Something is wrong';
  $hr->{'level'}   ||= 'info';
  my $time =  localtime(time);
  
  my $msg = '[' . $time . '] ' .  ' [' . $hr->{'level'} . '] ' .  $hr->{'message'} . "\n";
  
  my $filename = $self->{filename};
  
  if (-f $filename && -w $filename) {
    open(LOG, ">>", $filename) or warn "unable to open log file $filename, $!";
    select LOG;
    _write (*LOG, $msg);
    close(LOG);
  }
  else {
    print STDERR $msg;
  }
}
1;