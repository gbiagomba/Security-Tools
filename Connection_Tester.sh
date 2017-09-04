#!/bin/bash
#Author: Gilles Biagomba
#Program: Connection_Tester.sh
#Description: Checkes to see if you have a connection with a target host...as the name implies ;).\n

for IPs in $(cat targets);do
ping $IPs -c 3
nslookup $IPs
nmap -sU -p 443,80,25 $IPs
done
