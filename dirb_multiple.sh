#!/bin/bash
for url in $(cat targets);do
dirb $url /usr/share/dirbuster/wordlists/directory-list-1.0.txt -o /home/gilbia01/Projects/TCB/dirb_output.txt
done
