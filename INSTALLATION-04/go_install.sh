#!/usr/bin/env bash

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

# Install golang
apt install golang -y

# Build the go package in question
make dep                                     # to fetch dependencies
make tests                                   # to run the test suite
make check                                   # to check for any code style issue
make fix                                     # to automatically fix the code style using goimports
make build                                   # to build an executable for your host OS (not tested under windows) 
