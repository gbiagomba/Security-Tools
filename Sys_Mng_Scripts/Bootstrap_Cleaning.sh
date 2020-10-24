#!/usr/bin/env bash

# Check the current kernel version
uname -r

# Removing old kernels
for i in $(dpkg --list 'linux-image*'|awk '{ if ($1=="ii") print $2}'|grep -v `uname -r`); do apt-get purge $i; done
apt autoremove -y
update-grub