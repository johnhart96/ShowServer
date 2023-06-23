#!/bin/bash
# Project: ShowServer
# Author: johnhart96
# Version 1
# Licence: GNU Public Licence
# Repo: https://github.com/johnhart96/ShowServer
echo "Username:"
read del_user
smbpasswd -x $del_user
/usr/sbin/deluser $del_user