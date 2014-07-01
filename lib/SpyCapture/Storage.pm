package SpyCapture::Storage;

use strict;
use POSIX;
use Net::FTP;
use File::Path qw( mkpath );

use SpyCapture::Config	();
use SpyCapture::Logger	();


sub new {
  my ($class, %args) = @_;
  
  my $self = { %args };
  
  bless($self, $class);
  
  $self->{config} = SpyCapture::Config->new()->init();
  $self->{logger} = SpyCapture::Logger->new();
  $self->_init();
  
  return $self;
}

sub _init {
  my $self = shift;
  
  my $config = $self->{config};
  my $logger = $self->{logger};
  
  mkpath($config->{path_to_write}, 0700) if (! -d $config->{path_to_write});
  
  if (! -d $config->{path_to_write} || ! -w $config->{path_to_write}) {
    $logger->error("Unable to create $config->{path_to_write} : $!");
    die "Unable to create $config->{path_to_write} : $!";
  }
  
  return;
}

sub save_file {
  my ($self, $user, $pixbuf) = @_;
  
  my $config = $self->{config};
  my $logger = $self->{logger};
  my $storage_mode = $self->{storage_mode};
    
  if ($storage_mode eq 'ftp') {
    $self->_save_to_ftp($user, $pixbuf);
  }
  elsif ($storage_mode eq 'local') {
    $self->_save_to_local($user, $pixbuf);
  }
  else {
    $logger->warn("storage_type variable is not valid, using local disk");
    $self->_save_to_local($user, $pixbuf);
  }
  return;
}


sub _save_to_local {
  my ($self, $user, $pixbuf) = @_;
  
  my $config = $self->{config};
  my $logger = $self->{logger};
  
  my $local_time = strftime("%a_%b_%e_%H_%M_%Y", localtime());
 
  my $file_name = $config->{path_to_write} . '/' . $user . '_' . $local_time . '.png'; 
  
  $pixbuf->save($file_name, 'png');
  
  if (-e $file_name) {
    $logger->info("$file_name has been successfully saved on local disk");
  }
  else {
    $logger->error("Unable to save $file_name");
  }
  return;

}


sub _save_to_ftp {
  my ($self, $user, $pixbuf) = @_;
  
  my $config = $self->{config};
  my $logger = $self->{logger};
  
  my $local_time = strftime("%a_%b_%e_%H_%M_%Y", localtime());
  my $file_name = $user . '_' . $local_time . '.png';
  
  my $host = $config->{ftp_host};
  my $user = $config->{ftp_user};
  my $pass = $config->{ftp_pass};
  my $port = $config->{ftp_port} || '21';
  my $dir  = $config->{path_to_write} || '/';
  
  return $logger->error("you have choosed ftp storage location, but you didn't specify the ftp variables") unless(
      $host || $user || $pass
  );
  
  # we are saving the file on tmp location
  my $temp_file =  '/tmp/' . $file_name;
  $pixbuf->save($temp_file, 'png');
  
  if ( -e $temp_file) {
    my $ftp = Net::FTP->new(
	  $host, Passive => 1, 
	  Port => $port, 
	  Timeout => '100'
    ) or  return $logger->error("Can't connect to ftp server");
    
    $ftp->login($user, $pass) or return $logger->error("FTP Login Error! check your username and password, $ftp->message");
    
    unless ($ftp->cwd($dir)) {
      $ftp->mkdir( $dir, 1 );
      $ftp->cwd($dir);
    }
  
    $ftp->put($temp_file);
  
    if (defined($ftp->size($file_name))) {
      $logger->info("$file_name has been successfully saved on ftp");
    }
    else {
      $logger->error("unable to upload image file to ftp location: $ftp->message");
    }
    
    $ftp->quit();
    $ftp->close();
    
    unlink($temp_file);
  }
  else {
     $logger->error("Unable to save $file_name on tmp location");
  }
  return;  
}

1;
