# ShowServer
Show server is a all in one installer for installing a basic network services stack on a small lightweight linux machine (such as a Raspberry pi) that can serve the basic needs of an entertainment lighting network.

**The installer installs the following services:**
* SMB file sharing for saving lighting console show files or device configurations
* Time service for syncing date and times over network-time-protocal
* DHCP for serving IP addressess on the network
* Name service for assigning names to IP addresses, such as eos-console.lx.local = 10.101.100.101
* Network logging for devices that support syslog

**The installer installs the following packages:**
* sudo
* htop
* curl
* git
* zip
* unzip
* samba
* samba-common-bin
* ntp
* dnsmasq
* rsyslog

## How to use this installer
This installer asumes that you have just installed a fresh copy of debian and configured the IP addresses. It asumes that you have two interfaces one on your lighting network and the other connected to the internet.
```sh
 wget https://raw.githubusercontent.com/johnhart96/ShowServer/main/ShowServerInstall.sh 
 sudo bash ShowServerInstall.sh 
```

## Scripts
ShowServer includes a few scripts to automate common tasks. These are located in */usr/local/lx_network/bin*
| Script      | Description                                                        |
| ----------- | ------------------------------------------------------------------ |
| useradd.sh  | Run this script to create a user & add it to the file shares       |
| userrm.sh   | Remove a user                                                      |
| shareadd.sh | Create a new shared drive                                          |
