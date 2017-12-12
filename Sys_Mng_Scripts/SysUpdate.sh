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
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoclean
#apt-get autoremove -y
gem update
gem2.3 update
pause 'Press [Enter] key to continue...'
reboot
