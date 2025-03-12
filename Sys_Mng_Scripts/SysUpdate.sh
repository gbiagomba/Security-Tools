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

# Banner funct
function banner
{
    echo
    echo "--------------------------------------------------"
    echo "$1
    Current Time : $current_time"
    echo "--------------------------------------------------"
}

# Checking user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Figuring out the default package monitor
if hash apt 2> /dev/null; then
  PKGMAN_INSTALL="apt install -y --allow-downgrades"
  PKGMAN_UPDATE="apt update"
  PKGMAN_UPGRADE="apt upgrade -y || true; apt full-upgrade -y"
  PKGMAN_RM="apt autoremove -y"
  PKGMAN_CLEAN="apt clean -y"
elif hash yum; then
  PKGMAN_INSTALL="yum install -y --skip-broken"
  PKGMAN_UPDATE="yum update -y --skip-broken"
  PKGMAN_UPGRADE="yum upgrade -y --skip-broken"
  PKGMAN_RM="yum remove -y"
  PKGMAN_CLEAN="yum clean -y"
elif hash snap 2> /dev/null; then
  PKGMAN_INSTALL="snap install"
  PKGMAN_UPGRADE="snap refresh"
  PKGMAN_UPDATE=$PKGMAN_UPGRADE
  PKGMAN_RM="snap remove"
elif hash brew 2> /dev/null; then
  PKGMAN_INSTALL="brew install"
  PKGMAN_UPDATE="brew update"
  PKGMAN_UPGRADE="brew upgrade"
  PKGMAN_RM="brew uninstall"
fi

# Doing the basics
banner "system updates"
$PKGMAN_UPDATE
$PKGMAN_UPGRADE
$PKGMAN_RM
$PKGMAN_CLEAN

# Upgrading NPM packages
banner "NPM package updates"
npm update -g

# Updating all ruby packages
# gem2.5 update
banner "Gem Pakcage updates"
for i in $(gem list --local | cut -d " " -f 1); do echo $i; gem update $i; done

# Update all docker images
banner "Updating docker packages"
docker images |grep -v REPOSITORY|awk '{print $1}'|xargs -L1 docker pull

# Restart the machine
pause 'Press [Enter] key to continue...'
reboot now
