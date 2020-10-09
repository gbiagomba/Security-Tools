#!/usr/bin/env bash
# https://openwall.info/wiki/john/tutorials/Ubuntu-build-howto

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

# Installing pre-requisites:
for i in build-essential libssl-dev yasm libgmp-dev libpcap-dev libnss3-dev libkrb5-dev pkg-config libbz2-dev zlib1g-dev nvidia-cuda-toolkit nvidia-opencl-dev fglrx-updates-dev libopenmpi-dev openmpi-bin; do
	apt install $i -y
done

# Clone latest bleeding-edge Jumbo and build:
cd /opt/
git clone https://github.com/magnumripper/JohnTheRipper
cd JohnTheRipper/src/
bash configure && make && make install

# Test your build
john --test=0 --format=cpu
