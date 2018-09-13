#!/bin/bash
#Author: Gilles Biagomba
#Program: nikto_multiple.sh
#Description: This script runs nikto against a list of websites.\n
# 	      Simply place the desired websites in the targets file.\n
#	      Save and close the file, then run nikto_multiple.sh.\n
#	      This was written to help automate penetration testing\n
#	      and research purposes. It was not intented to be used\n
#	      maliciously, if used as such, I will not be held liable!\n
#PATH=$(pwd)

for url in $(cat targets);do
nikto -C all -h $url -o Nikto_Output-$(echo $web | tr -d "/"/"-" | sed 's/https:/https-/g').txt
done
