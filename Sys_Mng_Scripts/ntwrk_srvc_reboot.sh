#!/usr/bin/env bash
# Author: Gilles Biagomba
# Program: ntwrk_srvc_reboot.sh
# Description: Tests to see if you have an active internet connection and reboot your network services

# Checking if user is root
if [ "$EUID" -ne 0 ];then
	echo "Please run as root"
	exit
fi

# Checking dependencies
if [ ! -x $(which nmap) ]; then
	apt install nmap -y
fi

# Creating test envrionment
mkdir -p /tmp/Net-Tests/
cd /tmp/Net-Tests/

# Capturing request from user
echo
echo "--------------------------------------------------"
echo "Capturing request from user"
echo "--------------------------------------------------"
srvrname=$1
if [ -z $1 ] || [ -z $srvrname ]; then
	echo "Sorry you did not give me an input"
	echo "Usage: ./ntwrk_srvc_reboot.sh www.example.com"
	echo "But no worries, I will set it to google.com for you! :)"
	srvrname="www.google.com"
fi

# Declaring variables
STATUS1=$(ifconfig | grep -o -m 1 -h eth)
STATUS2=$(ifconfig | grep -o -m 1 -h wlan)
STATUS3=$(host $srvrname | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b")

function netreset
{
	# Checking internet status
	echo
	echo "--------------------------------------------------"
	echo "Checking internet status"
	echo "--------------------------------------------------"
	if [ "$STATUS1" != "eth" ] || [ "$STATUS2" != "wlan" ] || [ -z "$STATUS3" ]; then
		echo Restarting network services
		service networking restart
		service network-manager restart
	fi

	# Viewing IP address
	echo
	echo "--------------------------------------------------"
	echo "Viewing/Checking IP address"
	echo "--------------------------------------------------"
	ifconfig | aha > ip_address.html

	# Quick ping sweep
	echo
	echo "--------------------------------------------------"
	echo "Performing a quick pingsweep w/ nmap"
	echo "--------------------------------------------------"
	map -T5 --min-rate 300 -6 --resolve-all -PA21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000 -PS21-23,25,53,79,80-83,88,110,111,135,139,161,179,443,445,497,515,535,548,993,1025,1028,1029,1917,2869,3389,5000,5060,6000,8080,9001,9100,49000 -PU42,53,67-68,88,111,123,135,137,138,161,500,3389,535 -PY22,80,179,5060 -oA NetworkTest $srvrname
	xsltproc NetworkTest.xml -o NetworkTest.html

	# Viewing results
	echo
	echo "--------------------------------------------------"
	echo "Here are the results!"
	echo "--------------------------------------------------"
	firefox --new-tab ip_address.html NetworkTest.html &> /dev/null

	# Goodbye :)
	echo "Have a nice day :)"
} 2> /dev/null | tee -a $PWD/ntwrk_srvc_reboot.log

netreset
if [ -z `cat /tmp/Net-Tests/NetworkTest.gnmap | grep -o "0 hosts up"` ]; then
	netreset
fi
