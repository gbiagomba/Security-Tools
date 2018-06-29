#!/bin/bash
#Author: Gilles Biagomba
#Program: Network_Troubleshooter.sh
#Description: Tests to see if you have an active internet connection 

#Creating test envrionment
mkdir -p /tmp/Net-Tests/
cd /tmp/Net-Tests/

#Asking user for test IP/server address
echo "What IP or servername would you like to ping?"
read srvrname

#ping
pingsweep=($(ping -c 4 $srvrname | tee pingpong.txt | grep "failure" | cut -d " " -f 4))

#Use nmap 
nmap -A -Pn -R -sS -sU -oG NetworkTest $srvrname

#Resetting the network settings
service networking restart 
service network-manager restart 

