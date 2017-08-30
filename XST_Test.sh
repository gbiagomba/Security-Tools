#!/bin/bash
for IPs in $(cat targets);do
#Discover the supported methods
nmap -p 443 --script http-methods $IPs
#An example using cURL from the command line to send a TRACE request to a web server on the localhost with TRACE enabled
curl -v -X TRACE https://$IPs
curl -v -X TRACE http://$IPs
#In this example notice how we send a Cookie header with the request and it is also in the web server's response
curl -v -X TRACE -H "Cookie: name=value" https://$IPs
curl -v -X TRACE -H "Cookie: name=value" http://$IPs
done
