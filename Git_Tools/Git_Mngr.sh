#!/bin/bash
#Author: Gilles Biagomba
#Program: Git_Cloner.sh
#Description: This script was design to update or clone multiple git repos.\n
# 	      Open the GitLinks.txt file, copy all git links into it.\n
#	      Save and close the file, then run Git_Cloner.sh.\n

ls > GITPATHTEMP.txt
cat GITPATHTEMP.txt | grep -v GITPATHTEMP.txt > GITPATH.txt

for pths in $(cat GITPATH.txt);do
cd $pths
echo "----------------------------------------------------------"
echo "You are updating this Git repo:"
pwd
echo "----------------------------------------------------------"
git pull
cd ..
done

for links in $(cat GitLinks.txt);do
echo "----------------------------------------------------------"
echo "You are downloading this Git repo:"
echo $links
echo "----------------------------------------------------------"
git clone $links
done

rm GITPATHTEMP.txt GITPATH.txt
unset pths
unset links
set -u