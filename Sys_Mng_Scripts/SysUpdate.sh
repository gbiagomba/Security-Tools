#!/usr/bin/env bash
# Author: Gilles Biagomba
# Program: SysUpdater.sh
# Description: This script automates updating a debian based OS.\n
#  	      It was written on and for Kali2, because I was being lazy.\n

# Pause function
function pause()
{
   read -p "$*"
}

# Checking user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Ensuring system is debian based
OS_CHK=$(cat /etc/os-release | grep -o debian)
if [ "$OS_CHK" != "debian" ]; then
    echo "Unfortunately this install script was written for debian based distributions only, sorry!"
    exit
fi

# System update
apt update
apt upgrade -y --allow-downgrades
apt full-upgrade -y --allow-downgrades
apt autoclean
# apt autoremove -y

# Updating all ruby packages
# gem2.5 update
for i in $(gem list --local | cut -d " " -f 1); do echo $i; gem update $i; done

# Update all docker images
docker images |grep -v REPOSITORY|awk '{print $1}'|xargs -L1 docker pull

# Restart the machine
pause 'Press [Enter] key to continue...'

reboot
