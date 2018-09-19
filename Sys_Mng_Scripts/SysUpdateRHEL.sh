#!/bin/bash
#Author: Gilles Biagomba
#Program: SysUpdater.sh
#Description: This script automates updating a debian based OS.\n
# 	      It was written on and for Kali2, because I was being lazy.\n
# init
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
