#!/bin/bash
for url in $(cat targets);do
nikto -C all -h $url
done
