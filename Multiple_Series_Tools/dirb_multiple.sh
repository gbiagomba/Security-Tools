#!/bin/bash
#Author: Gilles Biagomba
#Program: dirb_multiple.sh
#Description: This script runs dirb against a list of websites.\n
# 	      Simply place the desired websites in the targets file.\n
#	      Save and close the file, then run dirb_multiple.sh.\n
#	      This was written to help automate penetration testing\n
#	      and research purposes. It was not intented to be used\n
#	      maliciously, if used as such, I will not be held liable!\n
#PATH=$(pwd)

#Setting up variables
n=0

for url in $(cat targets);do
	dirb $url /usr/share/dirbuster/wordlists/directory-list-1.0.txt -o dirb_output-"$((++n))".txt -w
done
