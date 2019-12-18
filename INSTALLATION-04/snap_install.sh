#!/usr/bin/env bash
# Reference: https://miloserdov.org/?p=2448

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

# Install the snap, start and add the service to autoload:
apt install snapd
systemctl start snapd
systemctl enable snapd

#  We also add apparmor to autoload (otherwise there will be an error): 
systemctl start apparmor
systemctl enable apparmor

# Adding snap to bashrc
echo "Snap configs" >> ~/.bashrc
echo "export PATH=$PATH:/snap/bin" >> ~/.bashrc
source ~/.bashrc

# Teting snap
snap find snap-store
snap install snap-store -y
