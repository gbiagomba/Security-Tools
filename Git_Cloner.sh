#!/bin/bash
for links in $(cat targets);do
echo "----------------------------------------------------------"
echo $links
echo "----------------------------------------------------------"
git clone $links
done

