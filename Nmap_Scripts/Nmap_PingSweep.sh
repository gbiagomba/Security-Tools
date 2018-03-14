# Variables - Set these
pth=$(pwd)

# Creating working envrionment
mkdir -p Nmap/Pingsweep/

# Nmap - Pingsweep using ICMP echo
nmap -sP -PE -iL $pth/targets -oA $pth/icmpecho -R
cat $pth/Nmap/Pingsweep/icmpecho.gnmap | grep Up | cut -d ' ' -f 2 > $pth/Nmap/Pingsweep/live
xsltproc $pth/Nmap/Pingsweep/icmpecho.xml -o icmpecho.html

# Nmap - Pingsweep using ICMP timestamp
nmap -sP -PP -iL $pth/targets -oA $pth/icmptimestamp -R
cat $pth/Nmap/Pingsweep/icmptimestamp.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/Nmap/Pingsweep/live
xsltproc $pth/Nmap/Pingsweep/icmptimestamp.xml -o icmptimestamp.html

# Nmap - Pingsweep using ICMP netmask
nmap -sP -PM -iL $pth/targets -oA $pth/icmpnetmask -R
cat $pth/Nmap/Pingsweep/icmpnetmask.gnmap | grep Up | cut -d ' ' -f 2 >> $pth/Nmap/Pingsweep/live
xsltproc $pth/Nmap/Pingsweep/icmpnetmask.xml -o icmpnetmask.html

# Systems that respond to ping (finding)
cat $pth/Nmap/Pingsweep/live | sort | uniq > $pth/livehosts
