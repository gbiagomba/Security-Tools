#!/bin/bash
# Author: Gilles Biagomba
# Program: SysUpdater.sh
# Description: This script automates updating a RHEL based OS.\n
#  	      It was written on Kali2, and tested on RHEL 6.\n
#  	      I wrote it because I was being lazy lol.\n

function pause()
{
   read -p "$*"
}
yum update
yum upgrade -y
yum dist-upgrade -y
yum autoclean
yum autoremove -y
gem update
gem2.3 update
pause 'Press [Enter] key to continue...'
reboot
