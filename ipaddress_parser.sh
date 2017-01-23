#!/bin/bash
filename='IP_Addresses.txt'
echo Start
while read p; do 
   ./ssltest $p 443
done < $filename
#will do it line by line using input redirection
