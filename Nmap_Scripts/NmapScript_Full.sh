# Variables - Set these
#pth=/root/Clients/CLIENTFOLDER
pth=$(pwd)

# Setting up workspace
mkdir -p ICMP PING SERV REPORTS

# Project name
echo "What is the name of the project?"
read workspace
echo

# HOST DISCOVERY

# Nmap - Pingsweep using ICMP echo
nmap -sP -PE -iL $pth/targets -oA $pth/icmpecho
cat $pth/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/live
xsltproc icmpecho.xml -o icmpecho.html

# Nmap - Pingsweep using ICMP timestamp
nmap -sP -PP -iL $pth/targets -oA $pth/icmptimestamp
cat $pth/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc icmptimestamp.xml -o icmptimestamp.html

# Nmap - Pingsweep using ICMP netmask
nmap -sP -PM -iL $pth/targets -oA $pth/icmpnetmask
cat $pth/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc icmpnetmask.xml -o icmpnetmask.html

# Systems that respond to ping (finding)
cat $pth/live | sort | uniq > $pth/pingresponse

# Nmap - Pingsweep using TCP SYN and UDP
nmap -sP -PS 21,22,23,25,53,80,88,110,111,135,139,443,445,8080 -iL $pth/targets -oA $pth/pingsweepTCP
nmap -sP -PU 53,111,135,137,161,500 -iL $pth/targets -oA $pth/pingsweepUDP
cat $pth/pingsweepTCP.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
cat $pth/pingsweepUDP.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc pingsweepTCP.xml -o pingsweepTCP.html
xsltproc pingsweepUDP.xml -o pingsweepUDP.html

# Create unique live hosts file
cat $pth/live | sort | uniq > $pth/livehosts

# PORT SCANNING

# Nmap - Full TCP SYN scan on live targets
nmap -sS -Pn -O -sV -T4 -R -p0-65535 --script=vulners -iL $pth/livehosts -oA $pth/TCPdetails
cat $pth/TCPdetails.gnmap | grep ' 25/open' | cut -d ' ' -f 2 > $pth/SMTP
cat $pth/TCPdetails.gnmap | grep ' 53/open' | cut -d ' ' -f 2 > $pth/DNS
cat $pth/TCPdetails.gnmap | grep ' 23/open' | cut -d ' ' -f 2 > $pth/telnet
cat $pth/TCPdetails.gnmap | grep ' 445/open' | cut -d ' ' -f 2 > $pth/SMB
cat $pth/TCPdetails.gnmap | grep ' 139/open' | cut -d ' ' -f 2 > $pth/netbios
cat $pth/TCPdetails.gnmap | grep http | grep open | cut -d ' ' -f 2 > $pth/http
cat $pth/TCPdetails.gnmap | grep ssl | grep open | cut -d ' ' -f 2 > $pth/ssh
cat $pth/TCPdetails.gnmap | grep ssl | grep open | cut -d ' ' -f 2 > $pth/ssl
xsltproc TCPdetails.xml -o TCPdetails.html

# Nmap - Default UDP scan on live targets
nmap -sU -Pn -T4 -iL $pth/livehosts -oA $pth/UDPdetails
cat $pth/UDPdetails.gnmap | grep ' 161/open\?\!|' | cut -d ' ' -f 2 > $pth/SNMP
cat $pth/UDPdetails.gnmap | grep ' 500/open\?\!|' | cut -d ' ' -f 2 > $pth/isakmp
xsltproc UDPdetails.xml -o UDPdetails.html

# Nmap - Finding zombie machines
nmap -F -iR 0 -O -R -sA -v -iL $pth/livehosts -oA $pth/Zombies
xsltproc $pth/Zombies.xml -o Zombies.html

# Nmap - Firewall evasion
nmap -f -mtu 24 --spoof-mac Dell --randomize-hosts -A -Pn -R -sS -sU -sV --script=vulners -iL $pth/livehosts -oA FW_Evade
nmap -D RND:10 --badsum --data-length 24 --randomize-hosts -A -Pn -R -sS -sU -sV --script=vulners -iL $pth/livehosts -oA FW_Evade2
#nmap -sI google.com --source-port 53 -Pn -R -sV --script=vulners -iL $pth/livehosts -oA FW_Evade3
xsltproc $pth/FW_Evade.xml -o FW_Evade.html
xsltproc $pth/FW_Evade2.xml -o FW_Evade2.html
#xsltproc $pth/FW_Evade3.xml -o FW_Evade3.html

# Nmap - Scan for possible vulnerabilities using vulners
# nmap -sV -sS -sU --script=vulners -R -iL target2 -A -p 0-65535-iL $pth/livehosts -oA $pth/VulScan

# Empty file cleanup
find $pth -size 0c -type f -exec rm -rf {} \;

# Organizing directory
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

# Gift wrap the findings ;)
zip -r $workspace.zip $pth
zipcloak $workspace.zip -O $workspace-secured.zip -q

# Send an email to the team!
#thunderbird -compose "to='email@example.com','attachment=blah.html'"
thunderbird -compose "to='jfoy@nbme.org,gbiagomba@nbme.org',cc='sgebeline@nbme.org',subject='$workspace Network Discovery Scan',body='The discovery scan finished and attached are the findings!',attachment='$pth/$workspace.zip"
