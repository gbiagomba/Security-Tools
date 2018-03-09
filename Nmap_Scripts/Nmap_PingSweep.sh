# Variables - Set these
#pth=/root/Clients/CLIENTFOLDER
pth=$(pwd)

# Nmap - Pingsweep using ICMP echo
nmap -sP -PE -iL $pth/targets -oA $pth/icmpecho -R
cat $pth/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/live
xsltproc icmpecho.xml -o icmpecho.html

# Nmap - Pingsweep using ICMP timestamp
nmap -sP -PP -iL $pth/targets -oA $pth/icmptimestamp -R
cat $pth/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc icmptimestamp.xml -o icmptimestamp.html

# Nmap - Pingsweep using ICMP netmask
nmap -sP -PM -iL $pth/targets -oA $pth/icmpnetmask -R
cat $pth/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/live
xsltproc icmpnetmask.xml -o icmpnetmask.html

# Systems that respond to ping (finding)
cat $pth/live | sort | uniq > $pth/pingresponse
