#!/bin/bash
for IPs in $(cat targets);do
openssl s_client -showcerts -connect $IPs | grep " Verify return code"
done
