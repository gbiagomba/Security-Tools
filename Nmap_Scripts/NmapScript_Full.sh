#!/usr/bin/env sh
# Author: Gilles Biagomba
# Program: NmapScrip_Full.sh
# Description: This script designed to perform a port knock scan of a target network.\n
#              It checks all 65,535 TCP/UDP ports using masscan.\n
#              Then it performs various ICMP scans using nmap followed with further targeted scans\n
#              Using the ports it found during the initial massscan scan we performed earlier.\n
#              The additional targeted scan consists of TCP SYN/ACK, UDP, and firewall evation scanning.\n
#              Lastly, the script will zip up the findings and email it to an email address you desire.\n
#              Side-note: You shouldd note this is the lightweight version,\n
#              that version skips some of the additional targeted scans.\n

# Variables - Set these
pth=$(pwd)

# Setting up workspace
mkdir -p ICMP PING SERV REPORTS
mkdir -p TCP UDP MASSCAN

# Prompting user for questions
echo "What is the name of the targetfile?"
echo "If the target file lives or is stored somewhere else,
You will need to specify the full path to that file"
read targetf
echo

echo "What is the name of the project?"
read workspace
echo

echo "What is the name of the zip (output) file you would like to use?
The zip file will be used to bundle/zip all the findings together"
read ZFILE
echo

echo "What is the password for the zip file?"
read ZPSS
echo

# Masscan - Used tro
echo
echo "Masscan - Checking all 65,535 ports"
masscan -iL $pth/$targetf -p 0-65535 --open-only -oL $pth/MASSCAN/masscan_output
OpenPORT=($(cat $pth/MASSCAN/masscan_output | cut -d " " -f 3 | grep -v masscan | sort | uniq))

# HOST DISCOVERY

# Nmap - Pingsweep using ICMP echo
echo
echo "Pingsweep using ICMP echo"
nmap -R -sP -PE -iL $pth/$targetf -oA $pth/icmpecho
cat $pth/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/live
xsltproc icmpecho.xml -o icmpecho.html

# Nmap - Pingsweep using ICMP timestamp
echo
echo "Pingsweep using ICMP timestamp"
nmap -R sP -PP -iL $pth/$targetf -oA $pth/icmptimestamp
cat $pth/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc icmptimestamp.xml -o icmptimestamp.html

# Nmap - Pingsweep using ICMP netmask
echo
echo "Pingsweep using ICMP netmask"
nmap -R -sP -PM -iL $pth/$targetf -oA $pth/icmpnetmask
cat $pth/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc icmpnetmask.xml -o icmpnetmask.html

# Systems that respond to ping (finding)
echo
echo "Sorting what systems responded to our previous array of pingsweeps"
cat $pth/live | sort | uniq > $pth/pingresponse

# Nmap - Pingsweep using TCP SYN and UDP
nmap -R -sP -PS 21,22,23,25,53,80,88,110,111,135,139,443,445,8080 -iL $pth/$targetf -oA $pth/pingsweepTCP
nmap -R -sP -PU 53,111,135,137,161,500 -iL $pth/$targetf -oA $pth/pingsweepUDP
cat $pth/pingsweepTCP.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
cat $pth/pingsweepUDP.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc pingsweepTCP.xml -o pingsweepTCP.html
xsltproc pingsweepUDP.xml -o pingsweepUDP.html

# Create unique live hosts file
cat $pth/live | sort | uniq > $pth/livehosts

# PORT SCANNING

# Nmap - Full TCP SYN scan on live $targetf
echo
echo "Stealth network mapping scan using TCP SYN packets"
nmap -R -sS -Pn -O -sV -T4 -R -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') --script=vulners -iL $pth/livehosts -oA $pth/TCPdetails
cat $pth/TCPdetails.gnmap | grep ' 25/open' | cut -d ' ' -f 2 > $pth/SMTP
cat $pth/TCPdetails.gnmap | grep ' 53/open' | cut -d ' ' -f 2 > $pth/DNS
cat $pth/TCPdetails.gnmap | grep ' 23/open' | cut -d ' ' -f 2 > $pth/telnet
cat $pth/TCPdetails.gnmap | grep ' 445/open' | cut -d ' ' -f 2 > $pth/SMB
cat $pth/TCPdetails.gnmap | grep ' 139/open' | cut -d ' ' -f 2 > $pth/netbios
cat $pth/TCPdetails.gnmap | grep http | grep open | cut -d ' ' -f 2 > $pth/http
cat $pth/TCPdetails.gnmap | grep ssl | grep open | cut -d ' ' -f 2 > $pth/ssh
cat $pth/TCPdetails.gnmap | grep ssl | grep open | cut -d ' ' -f 2 > $pth/ssl
xsltproc TCPdetails.xml -o TCPdetails.html

# Nmap - Default UDP scan on live $targetf
echo
echo "Stealth network mapping scan using UDP packets"
nmap -R -sU -Pn -T4 --R -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') --script=vulners -iL $pth/livehosts -oA $pth/UDPdetails
cat $pth/UDPdetails.gnmap | grep ' 161/open\?\!|' | cut -d ' ' -f 2 > $pth/SNMP
cat $pth/UDPdetails.gnmap | grep ' 500/open\?\!|' | cut -d ' ' -f 2 > $pth/isakmp
xsltproc UDPdetails.xml -o UDPdetails.html

# Nmap - Finding zombie machines
echo
echo "Stealth network mapping scan using TCP ACK Packets"
nmap -iR 0 -O -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') -R -sA -v -iL $pth/livehosts -oA $pth/Zombies
xsltproc $pth/Zombies.xml -o Zombies.html

# Nmap - Firewall evasion
echo
echo "Stealth network mapping scan with Firewall evasion techniques"
# nmap -D RND:10 --badsum --data-length 24 --mtu 24 --spoof-mac Dell --randomize-hosts -A -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') -Pn -R -sS -sU -sV -iL $pth/livehosts --script=vulners -oA FW_Evade
nmap -f -mtu 24 --randomize-hosts --reason --resolve-all --spoof-mac Dell -T2 -A -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') -Pn -R -sS -sU -sV --script=vulners -iL $pth/livehosts -oA FW_Evade
nmap -D RND:10 --badsum --data-length 24 --randomize-hosts -reason --resolve-all -T2 -A -p $(echo ${OpenPORT[*]} | sed 's/ /,/g') -Pn -R -sS -sU -sV --script=vulners -iL $pth/livehosts -oA FW_Evade2
xsltproc $pth/FW_Evade.xml -o FW_Evade.html

# Empty file cleanup
find $pth -size 0c -type f -exec rm -rf {} \;

# Organizing directory
cd $pth
mv *.html REPORTS/
mv icmp*.* ICMP/
mv ping*.* PING/
mv SMTP SERV/
mv DNS SERV/
mv telnet SERV/
mv SMB SERV/
mv netbios SERV/
mv http SERV/
mv ssh SERV/
mv ssl SERV/
mv SNMP SERV/
mv isakmp SERV/
mv FW_Evade*.* TCP/
mv UDPdetails.* UDP/ 
mv TCPdetails.* TCP/

# Gift wrap the findings ;)
echo "Compressing the output into a pretty package...I promise it will come with a bowtie!"
zip --password $ZPSS -ru -9 $pth/../$workspace-$ZFILE.zip $pth
# zipcloak $workspace.zip -O $workspace-secured.zip -q

# Send an email to the team!
#thunderbird -compose "to='email@example.com','attachment=blah.html'"
thunderbird -compose "to='itsecurity@nbme.org',cc='sgebeline@nbme.org',subject='$workspace Network Discovery Scan',body='The discovery scan finished and attached are the findings!',attachment='$pth/../$workspace-$ZFILE.zip'"

# De-initializing viarables
unset pth
unset OpenPORT
unset targetf
unset ZFILE
unset ZPSS
set -u
