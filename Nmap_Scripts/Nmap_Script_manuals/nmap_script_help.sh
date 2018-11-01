#!/bin/sh
for links in $(cat scripts);do
	echo $links
	wget "https://nmap.org/nsedoc/scripts/$links.html"
done
