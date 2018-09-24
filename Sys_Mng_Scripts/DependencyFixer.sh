#!/bin/bash
# Author: Gilles Biagomba
# Program: DependencyFixer.sh
# Description: This script written to automatically resolve software dependency issues.\n
#  	      In other words if you are getting the apt --fix-broken error.\n
# 	      THis could help you resolve that issue or other related issues.\n

apt-get autoremove
apt-get --purge remove
apt-get autoclean
apt-get -f install -y
apt-get install --fix-broken -y
apt-get install --reinstall software-properties-common -y
apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
dpkg --configure -a
