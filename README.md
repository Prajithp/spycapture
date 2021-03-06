SpyCapture
==========

Simple spy screen capture for linux - ONLY tested on debian based distros.


###Requirements:

* Gtk2
* File::Pid
* POSIX           # CORE module
* Net::FTP        # CORE module since perl 5.7.3
* File::Path      # CORE module since perl 5.001
* IPC::Open3      # CORE module since perl 5.000

On Ubuntu, all the packages can be installed directly from the universal repo using the following command:

```
apt-get install libglib-perl libgtk2-perl libgtk2-perl-doc libpango-perl libfile-pid-perl 
```
OR You can also use  cpanminus to install those modules, simply execute the command below as root or using sudo

```
curl -L http://cpanmin.us | perl - module name here
              OR
cpan install module name here              

# If you don't have curl but wget, replace `curl -L` with `wget -O -`.
```

###INSTALL

Download the zip archive or clone the source code into the PC and follow the below instructions.

Copy lib, bin and etc folders to /usr/local/spycapture/ and set executable permission to the perl script
```
mkdir /usr/local/spycapture
cp -r lib /usr/local/spycapture/
cp -r bin /usr/local/spycapture/
chmod 700 /usr/local/spycapture/bin/spycapture.pl
```
Create a symlink to OS command PATH
```
ln -s /usr/local/spycapture/bin/spycapture.pl /usr/local/bin/spycapture
```

###Configuration

Modify the configuration file "/usr/local/spycapture/etc/spycapture.conf" as per your needs. 
