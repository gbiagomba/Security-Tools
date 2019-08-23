#!/bin/bash
#Author: Gilles Biagomba
#Program: vision2_multiple.sh
#Description: This script was design to allow the user to run multiple nmap xml files.\n
# 	      against the vision2 script which will try to find vulnerabilities on NVD.\n
#	      https://github.com/CoolerVoid/Vision2 \n

#Assigned the working directory path to the variable PATH
PATH=$(pwd)

#Loop through the various xml files and output content
#Attempting to troubleshoot line below!
for c in $(cat "$PATH/*.xml"); do
  echo $c
  echo "-----------------------------------------------------------------------------------------------------------"
  echo "File: $c"
  echo "-----------------------------------------------------------------------------------------------------------"
  python /opt/Nmap_Extentions/Vision2/vision2.py -f "$PATH/$c" -l 5 -o "$PATH/$c.txt"
done

#reset the variable to NULL
PATH=""
