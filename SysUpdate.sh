#!/bin/bash
# init
function pause()
{
   read -p "$*"
}
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoclean
apt-get autoremove -y
gem update
pause 'Press [Enter] key to continue...'
reboot
