# Variables - Set these
pth=$(pwd)

# Nmap - Pingsweep using ICMP echo
nmap -sP -PE -iL $pth/targets -oA $pth/icmpecho -R
cat $pth/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/live
xsltproc $pth/icmpecho.xml -o icmpecho.html

# Nmap - Pingsweep using ICMP timestamp
nmap -sP -PP -iL $pth/targets -oA $pth/icmptimestamp -R
cat $pth/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc $pth/icmptimestamp.xml -o icmptimestamp.html

# Nmap - Pingsweep using ICMP netmask
nmap -sP -PM -iL $pth/targets -oA $pth/icmpnetmask -R
cat $pth/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc $pth/icmpnetmask.xml -o icmpnetmask.html

# Systems that respond to ping (finding)
cat $pth/live | sort | uniq > $pth/livehosts

# FInal scan
nmap -A -F -Pn -R -sS -sU -sV -iL $pth/livehosts -oA FInal
