#!/bin/bash  
# Project: ShowServer
# Author: johnhart96
# Version 1
# Licence: GNU Public Licence
# Repo: https://github.com/johnhart96/ShowServer

# Base Packages
echo "Installing base packages"
apt update
apt upgrade -y
apt install sudo htop curl git zip unzip -y
clear
echo "What is your admin username?"
read admin_user
/usr/sbin/usermod -aG sudo $admin_user



# Samba
echo "Installing file sharing..."
apt install samba samba-common-bin -y
smbpasswd -a $admin_user
/usr/sbin/ groupadd lx_shares
/usr/sbin/usermod -aG lx_shares $admin_user
mkdir -p /usr/local/lx_network/shares/show_files
mkdir -p /usr/local/lx_network/shares/configs
mkdir -p /usr/local/lx_network/shares/services
chown $admin_user:lx_shares /usr/local/lx_network/shares/show_files
chown $admin_user:lx_shares /usr/local/lx_network/shares/configs
chown $admin_user:lx_shares /usr/local/lx_network/shares/services
chmod 770 /usr/local/lx_network/shares/show_files
chmod 770 /usr/local/lx_network/shares/configs
chmod 770 /usr/local/lx_network/shares/services
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
chmod 777 /usr/local/lx_network/shares/services/file_sharing.conf
systemctl restart smbd

# NTP
echo "Installing time service..."
apt-get install ntp -y
ntpq -p
ln -n /etc/ntp.conf /usr/local/lx_network/shares/services/time.conf
chmod 777 /usr/local/lx_network/shares/services/time.conf

# DHCP & DNS
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
echo "dhcp-option=option:syslog-server,$this_server" >> /etc/dnsmasq.conf
echo "dhcp-option=option:netmask,$dhcp_subnet" >> /etc/dnsmasq.conf
echo "dhcp-leasefile=/usr/local/lx_network/dhcp_leases.txt" >> /etc/dnsmasq.conf
echo "dhcp-authoritative" >> /etc/dnsmasq.conf
echo "domain-needed" >> /etc/dnsmasq.conf
echo "bogus-priv" >> /etc/dnsmasq.conf
echo "listen-address=$this_server" >> /etc/dnsmasq.conf
echo "expand-hosts" >> /etc/dnsmasq.conf
echo "domain=lx.local" >> /etc/dnsmasq.conf
ln -n /etc/dnsmasq.conf /usr/local/lx_network/shares/services/network_address.conf
chmod 777 /usr/local/lx_network/shares/services/network_address.conf
rm -rf /etc/hosts
echo "127.0.0.1 localhost" >> /etc/hosts
echo "$this_server $server_name $server_name.lx.local" >> /etc/hosts 
ln -n /etc/hosts /usr/local/lx_network/shares/services/names.conf
chmod 777 /usr/local/lx_network/shares/services/names.conf
systemctl restart dnsmasq

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
