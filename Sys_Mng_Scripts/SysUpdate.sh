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

apt update
apt upgrade -y
apt full-upgrade -y
apt autoclean
apt autoremove -y

gem2.3 update

pause 'Press [Enter] key to continue...'

reboot
