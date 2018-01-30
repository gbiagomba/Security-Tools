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

#System update
apt update
apt upgrade -y --allow-downgrades
apt full-upgrade -y --allow-downgrades
apt autoclean
apt autoremove -y

#Updating all ruby packages
gem2.3 update

pause 'Press [Enter] key to continue...'

reboot
