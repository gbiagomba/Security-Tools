# Setting up work envrionment
mkdir -p fw_evade icmpecho icmptimestamp icmpnetmask masscan report

# Variables - Set these
pth=$(pwd)

# Masscan - Checking the top 100 TCP/UDP ports used
echo
echo "Masscan - Checking the top 100 TCP/UDP ports used"
masscan -iL $pth/targets -p 7,9,13,17,19,37,49,53,80,88,106,111,113,119,120,123,135,139,158,177,179,199,389,427,443,445,465,497,500,518,520,548,554,587,593,623,626,631,646,873,990,993,995,1110,1433,1701,1720,1723,1755,1900,2000,2049,2121,2717,3000,3128,3283,3306,3389,3456,3703,3986,4444,4500,4899,5000,5009,5051,5060,5101,5190,5353,5357,5432,5631,5632,5666,5800,5900,6646,7070,8000,8443,8888,9100,9200,10000,17185,20031,30718,31337,32768,32771,32815,33281,49156,49188,65024,1022-1023,1025-1029,1025-1030,110-111,135-139,143-144,1433-1434,161-162,1645-1646,1718-1719,1812-1813,2000-2001,2048-2049,21-23,2222-2223,25-26,32768-32769,443-445,49152-49154,49152-49157,49181-49182,49185-49186,49190-49194,49200-49201,513-515,514-515,543-544,6000-6001,67-69,79-81,8008-8009,8080-8081,996-999,9999-10000 --open-only -oL $pth/masscan/masscan_output

# Nmap - Pingsweep using ICMP echo
echo
echo "Pingsweep using ICMP echo"
nmap -sP -PE -iL $pth/targets -oA $pth/icmpecho/icmpecho -R
cat $pth/icmpecho/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/live
xsltproc $pth/icmpecho/icmpecho.xml -o report/icmpecho.html

# Nmap - Pingsweep using ICMP timestamp
echo
echo "Pingsweep using ICMP timestamp"
nmap -sP -PP -iL $pth/targets -oA $pth/icmptimestamp/icmptimestamp -R
cat $pth/icmptimestamp/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc $pth/icmptimestamp/icmptimestamp.xml -o report/icmptimestamp.html

# Nmap - Pingsweep using ICMP netmask
echo
echo "Pingsweep using ICMP netmask"
nmap -sP -PM -iL $pth/targets -oA $pth/icmpnetmask/icmpnetmask -R
cat $pth/icmpnetmask/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc $pth/icmpnetmask/icmpnetmask.xml -o report/icmpnetmask.html

# Systems that respond to ping (finding)
echo
echo "Sorting what systems responded to our previous array of pingsweeps"
cat $pth/live | sort | uniq > $pth/livehosts

# FInal scan
echo
echo "Stealth network mapping scan"
nmap -A -F -Pn -R -sS -sU -sV -iL $pth/livehosts -oA FInal

# Nmap - Firewall evasion
echo
echo "Stealth network mapping scan with Firewall evasion techniques"
nmap -D RND:10 --badsum --data-length 24 --mtu 24 --spoof-mac Dell --randomize-hosts -A -F -Pn -R -sS -sU -sV -iL $pth/livehosts --script=vulners -oA $pth/fw_evade/FW_Evade
xsltproc $pth/fw_evade/FW_Evade.xml -o $pth/report/FW_Evade.html

# Empty file cleanup
find $pth -size 0c -type f -exec rm -rf {} \;
