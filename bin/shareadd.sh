#!/bin/bash
# Project: ShowServer
# Author: johnhart96
# Version 1
# Licence: GNU Public Licence
# Repo: https://github.com/johnhart96/ShowServer
echo "What is the new share name?"
read share_name
mkdir -p /usr/local/lx_network/shares/$share_name
chown root:lx_shares /usr/local/lx_network/shares/$share_name
chmod 770 /usr/local/lx_network/shares/$share_name
echo "[$share_name]" >> /etc/samba/smb.conf
echo "path = /usr/local/lx_network/shares/$share_name" >> /etc/samba/smb.conf
echo "writeable = yes" >> /etc/samba/smb.conf
echo "guest ok = yes" >> /etc/samba/smb.conf
systemctl restart smb