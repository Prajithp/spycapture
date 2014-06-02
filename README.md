SpyCapture
==========

Simple spy screen capture for linux


Using it is as simple as following those two steps.

#####Requirements:

* Gtk2
* File::Pid
* POSIX        # CORE module
* Net::FTP     # CORE module since perl 5.7.3
* File::Path   # CORE module since perl 5.001
* IPC::Open3   # CORE module since perl 5.000

On Ubuntu, all the packages can be installed directly from the universal repo using the following command:

```
apt-get install libglib-perl libgtk2-perl libgtk2-perl-doc libpango-perl libfile-pid-perl 
```
OR You can also use the cpanminus to install those modules, simply execute the command below as root or using sudo

```
curl -L http://cpanmin.us | perl - module name here

# If you don't have curl but wget, replace `curl -L` with `wget -O -`.
```

#####INSTALL

Download the zip archive or clone the source code into the PC and follow the below instructions for installation, 

