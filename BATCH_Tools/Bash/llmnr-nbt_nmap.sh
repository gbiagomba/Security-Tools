#!/usr/bin/env sh

# setting up work env
mkdir nmap masscan

# masscan
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output1 --open-only --shards 1/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output2 --open-only --shards 2/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output3 --open-only --shards 3/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output4 --open-only --shards 4/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output5 --open-only --shards 5/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output6 --open-only --shards 6/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output7 --open-only --shards 7/8
masscan -iL targets -p T:139,445,U:137-139,5355 -oL masscan/masscan_output8 --open-only --shards 8/8
cat masscan/masscan_output* | sort | uniq > masscan_combined

# nmap
nmap -A -R --resolve-all -sS -sV -sU -T4 --script=broadcast-netbios-master-browser,llmnr-resolve,nbstat,vulners -iL targets -p T:139,445,U:137-139,5355 --reason -oA nmap/LLMNR-NBT-SMB
xsltproc LLMNR-NBT-SMB.xml LLMNR-NBT-SMB.html
