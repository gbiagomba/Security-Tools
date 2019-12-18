#!/usr/bin/env bash

#Author: Gilles S. Biagomba
#Program: $Tron
#Description: This program automates the Ubuntu 8 to 10 upgrade. \n

#Log everything happening
#script

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

#Announcement
echo 'This Script is going to update all the packages'
echo 'Then it will upgrade the entire system to the next LTS'

#Checks to see what OS & Kernel are installed
lsb_release -a >> /root/OS_installed.txt
uname -a >> /root/kernel_installed.txt

#Check to see what applications are installed
dpkg --list >> /root/packages_installed.txt

#Change the repository files for apt-get since 8 is no longer supported
sed -i -e 's/archive.ubuntu.com\|security.ubuntu.com/old-releases.ubuntu.com/g' /etc/apt/sources.list

#installs unattended-upgrades
apt-get install unattended-upgrades --yes
dpkg-reconfigure unattended-upgrades --yes

#Launch the system upgrade
do-release-upgrade -f DistUpgradeViewNonInteractive

#Check for updates and upgrades
apt-get update --yes
apt-get upgrade --yes

#Cleaning up the mess
apt-get autoclean
apt-get clean
apt-get check

#restart the box
shutdown -r now
