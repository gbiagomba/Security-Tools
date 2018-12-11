#!/usr/bin/env bash
# Author: Gilles Biagomba
# Program: ntwrk_srvc_reboot.sh
# Description: Tests to see if you have an active internet connection and reboot your network services

# Creating test envrionment
mkdir -p /tmp/Net-Tests/
cd /tmp/Net-Tests/

# Declaring variables
STATUS1=$(ifconfig | grep -o -m 1 -h eth)
STATUS2=$(ifconfig | grep -o -m 1 -h wlan)

# Capturing request from user
srvrname=$1
if [ -z $1 ] || [ -z $srvrname ]; then
	echo "Sorry you did not give me an input"
	echo "Usage: ./ntwrk_srvc_reboot.sh example.com"
	exit
fi

# Checking internet status
if [ "$STATUS1" != "eth" ] || [ "$STATUS2" != "wlan" ]; then
	service networking restart
	service network-manager restart
fi

# Viewing IP address
ifconfig | aha > ip_address.html

# Quick ping sweep
nmap -PE -PM -PP -R --reason --resolve-all -sP -oA NetworkTest $srvrname
xsltproc NetworkTest.xml -o NetworkTest.html

# Viewing results
gnome-terminal --tab -- firefox --new-tab ip_address.html NetworkTest.html &

# ALL
echo "Have a nice day :)"
