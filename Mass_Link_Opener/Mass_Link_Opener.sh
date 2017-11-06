#!/bin/bash
#Author: Gilles Biagomba
#Program: mass_link_opener.sh
#Description: This script was written to open multiple links in a text file.\n
for links in $(cat links.txt);do
echo "----------------------------------------------------------"
echo "You are downloading G-Drive Link:"
echo $links
echo "----------------------------------------------------------"
firefox --new-tab $links
done

