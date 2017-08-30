#!/bin/bash
for links in $(cat GitLinks.txt);do
echo "----------------------------------------------------------"
echo "You are downloading this repo:"
echo $links
echo "----------------------------------------------------------"
git clone $links
done

