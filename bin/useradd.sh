#!/bin/bash
# Project: ShowServer
# Author: johnhart96
# Version 1
# Licence: GNU Public Licence
# Repo: https://github.com/johnhart96/ShowServer
echo "ShowServer - User creation script"
echo "================================="
echo "Username:"
read new_user

/usr/sbin/adduser $new_user
smbpasswd -a $new_user
/usr/sbin/usermod -aG lx_shares $new_user
