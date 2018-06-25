#!/bin/bash
#Author: Gilles Biagomba
#Program: CertChecker.sh
#Description: This script was designed to pull the certificate of websites in the targets file.\n

for IPs in $(cat targets);do
openssl s_client -showcerts -connect $IPs | grep " Verify return code"
done
