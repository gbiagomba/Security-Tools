# Setting up work envrionment
mkdir -p icmpecho icmptimestamp icmpnetmask report

# Variables - Set these
pth=$(pwd)

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
