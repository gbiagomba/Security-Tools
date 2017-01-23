#!/bin/bash
for IPs in $(cat targets);do
ping $IPs
nslookup $IPs
nmap -sU -p 443,80,25 $IPs
done
