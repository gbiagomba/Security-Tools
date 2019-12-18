#!/usr/bin/env bash

#Author: Gilles Biagomba
#Program: install_cuckoodroid.sh
#Description: This script was written to automate the installation of cuckoodroid.\n
# https://github.com/idanr1986/cuckoodroid-2.0

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

cd /opt/
git clone https://github.com/idanr1986/cuckoodroid-2.0
cd cuckoodroid-2.0
apt-get install -y python git python-pip
apt-get install -y libffi-dev libssl-dev libxml2-dev libxslt1-dev libjpeg8-dev zlib1g-dev
pip install -r requirements.txt
#apt-get install -y qemu-kvm libvirt-bin # when using esx server
