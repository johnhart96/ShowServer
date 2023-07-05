#!/bin/bash  
# Project: ShowServer
# Author: johnhart96
# Version 1
# Licence: GNU Public Licence
# Repo: https://github.com/johnhart96/ShowServer

clear
echo "Show Server - Installer v1"
echo "=========================="
echo "This installer will install your basic network stack for your lighting network"
echo "It asumes that you have already configured your networks configured and the 2nd one will be used for your lighting network"
echo "If this is not the case, press CTRL+C to cancel the installer"
echo "You will need to be running this installer as root not using sudo!"
echo " "
echo "Press enter to proceed"
read


# Base Packages
echo "Installing base packages"
apt update
apt upgrade -y
apt install sudo htop curl git zip unzip avahi-utils -y
clear
echo "What is your admin username? (not root)"
read admin_user
echo "Adding $admin_user to sudo..."
/usr/sbin/usermod -aG sudo $admin_user
echo "What would you like your internal domain to be? (lx.local):"
read intenal_domain




# Samba
echo "Installing file sharing..."
apt install samba samba-common-bin -y
echo "You are about to be asked to enter your file sharing password"
echo "Press enter to continue"
read
smbpasswd -a $admin_user
echo "Creating the lx_shares group..."
/usr/sbin/groupadd lx_shares
echo "Adding $admin_user to the lx_shares group"
/usr/sbin/usermod -aG lx_shares $admin_user
echo "Creating share directories..."
mkdir -p /usr/local/lx_network/shares/show_files
mkdir -p /usr/local/lx_network/shares/configs
mkdir -p /usr/local/lx_network/shares/services
echo "Changing share ownership..."
chown $admin_user:lx_shares /usr/local/lx_network/shares/show_files
chown $admin_user:lx_shares /usr/local/lx_network/shares/configs
chown $admin_user:lx_shares /usr/local/lx_network/shares/services
echo "Setting share permissions..."
chmod 770 /usr/local/lx_network/shares/show_files
chmod 770 /usr/local/lx_network/shares/configs
chmod 770 /usr/local/lx_network/shares/services
echo "Configuring file shares..."
echo "server min protocol = NT1" >> /etc/samba/smb.conf
echo "lanman auth = yes" >> /etc/samba/smb.conf
echo "ntlm auth = yes" >> /etc/samba/smb.conf
echo "guest account = nobody" >> /etc/smb.conf
echo "syslog only = yes" >> /etc/smb.conf
echo "syslog = 3" >> /etc/smd.conf
echo "# LX Network" >> /etc/samba/smb.conf
echo "[ShowFiles]" >> /etc/samba/smb.conf
echo "path = /usr/local/lx_network/shares/show_files" >> /etc/samba/smb.conf
echo "writeable = yes" >> /etc/samba/smb.conf
echo "guest ok = yes" >> /etc/samba/smb.conf
echo "[Configs]" >> /etc/samba/smb.conf
echo "path = /usr/local/lx_network/shares/configs" >> /etc/samba/smb.conf
echo "writeable = yes" >> /etc/samba/smb.conf
echo "guest ok = yes" >> /etc/samba/smb.conf
echo "[Services]" >> /etc/samba/smb.conf
echo "path = /usr/local/lx_network/shares/services" >> /etc/samba/smb.conf
echo "writeable = yes" >> /etc/samba/smb.conf
echo "guest ok = yes" >> /etc/samba/smb.conf
ln -n /etc/samba/smb.conf /usr/local/lx_network/shares/services/file_sharing.conf
ln -n /etc/network/interfaces /usr/local/lx_network/shares/services/network_interfaces.conf
chmod 777 /usr/local/lx_network/shares/services/file_sharing.conf
sudo chmod 777 /usr/local/lx_network/shares/services/network_interfaces.conf
systemctl restart smbd
echo "Done installing file sharing"

# NTP
echo "Installing time service..."
apt-get install ntp -y
ntpq -p
ln -n /etc/ntp.conf /usr/local/lx_network/shares/services/time.conf
chmod 777 /usr/local/lx_network/shares/services/time.conf
echo "Done installing time service"

# DHCP & DNS
echo "Do you want to install network address services? (Y,n):"
read dhcp_question
if [ "$dhcp_question" != "${dhcp_question#[Yy]}" ] ;then 
    echo "Installing network address services..."
    apt install dnsmasq -y
    echo "What is your DHCP Range? (192.168.0.1,192.168.0.254):"
    read dhcp_range
    echo "What is your Subnet mask? (255.255.255.0):"
    read dhcp_subnet
    this_server=$(hostname  -I | cut -f2 -d' ')
    server_name=$(hostname)
    rm -rf /etc/dnsmasq.conf
    echo "dhcp-range=$dhcp_range,12h" >> /etc/dnsmasq.conf
    echo "dhcp-option=option:ntp-server,$this_server" >> /etc/dnsmasq.conf
    echo "dhcp-option=option:dns-server,$this_server" >> /etc/dnsmasq.conf
    echo "dhcp-option=option:netmask,$dhcp_subnet" >> /etc/dnsmasq.conf
    echo "dhcp-leasefile=/usr/local/lx_network/dhcp_leases.txt" >> /etc/dnsmasq.conf
    echo "dhcp-authoritative" >> /etc/dnsmasq.conf
    echo "domain-needed" >> /etc/dnsmasq.conf
    echo "bogus-priv" >> /etc/dnsmasq.conf
    echo "listen-address=$this_server" >> /etc/dnsmasq.conf
    echo "expand-hosts" >> /etc/dnsmasq.conf
    echo "domain=$intenal_domain" >> /etc/dnsmasq.conf
    ln -n /etc/dnsmasq.conf /usr/local/lx_network/shares/services/network_address.conf
    chmod 777 /usr/local/lx_network/shares/services/network_address.conf
    rm -rf /etc/hosts
    echo "127.0.0.1 localhost" >> /etc/hosts
    echo "$this_server $server_name $server_name.$internal_domain" >> /etc/hosts 
    ln -n /etc/hosts /usr/local/lx_network/shares/services/names.conf
    chmod 777 /usr/local/lx_network/shares/services/names.conf
    systemctl restart dnsmasq
    echo "Done installing network address service"
fi


# Syslog
echo "Installing logging service..."
apt install rsyslog -y
echo 'module(load="imudp")' >> /etc/rsyslog.conf
echo 'input(type="imudp" port="514")' >> /etc/rsyslog.conf
echo 'module(load="imtcp")' >> /etc/rsyslog.conf
echo 'input(type="imtcp" port="514")' >> /etc/rsyslog.conf
echo '$template remote-incoming-logs,"/var/log/%HOSTNAME%/%PROGRAMNAME%.log"' >> /etc/rsyslog.conf
echo "*.* ?remote-incoming-logs" >> /etc/rsyslog.conf
ln -n /etc/rsyslog.conf /usr/local/lx_network/shares/services/logging.conf
chmod 777 /usr/local/lx_network/shares/services/logging.conf
systemctl restart rsyslog
echo "Done installing logging service"

# Webmin
echo "Would you like to install webmin? (y,n):"
read webmin_question
if [ "$webmin_question" != "${webmin_question#[Yy]}" ] ;then 
    echo "deb http://download.webmin.com/download/repository sarge contrib" >> /etc/apt/sources.list
    wget -q -O- http://www.webmin.com/jcameron-key.asc | sudo apt-key add
    apt update
    apt install webmin -y
fi

# User Scripts
echo "Downloading user scripts..."
mkdir /usr/local/lx_network/bin
chown root:lx_shares /usr/local/lx_network/bin
chmod 770 /usr/local/lx_network/bin
wget https://raw.githubusercontent.com/johnhart96/ShowServer/main/bin/useradd.sh -O /usr/local/lx_network/bin/useradd.sh
wget https://raw.githubusercontent.com/johnhart96/ShowServer/main/bin/userrm.sh -O /usr/local/lx_network/bin/userrm.sh
wget https://raw.githubusercontent.com/johnhart96/ShowServer/main/bin/shareadd.sh -O /usr/local/lx_network/bin/shareadd.sh
chmod +x -R /usr/local/lx_network/bin/