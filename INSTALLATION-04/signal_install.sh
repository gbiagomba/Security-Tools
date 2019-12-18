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

curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add -
echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list
apt update
apt install signal-desktop -y

#curl -s https://updates.signal.org/desktop/apt/keys.asc | sudo apt-key add - && echo "deb [arch=amd64] https://updates.signal.org/desktop/apt xenial main" | sudo tee -a /etc/apt/sources.list.d/signal-xenial.list && sudo apt update && sudo apt install signal-desktop
