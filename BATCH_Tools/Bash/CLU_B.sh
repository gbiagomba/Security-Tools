#!/usr/bin/env bash

#Author: Gilles S. Biagomba
#Program: Codified Likeness Utility or CLU
#Description: This program is designed to remove the default share-point(s) and add the desired share-point. \n
#contd. then it changes the share-point user owner, user group and file permissions \n
#contd. then it opens the server application so that the user may double check every was done correctly \n
#contd. Lastly, it starts the Server services (caching, web, afp and smb), \n
#contd. copyright © 2014-2015 David's Bridal Inc. All Rights Reserved.

# Checking user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Ensuring system is debian based
OS_CHK=$(cat /etc/os-release | grep -o debian)
if [ "$OS_CHK" != "Maverick" ]; then
    echo "Unfortunately this install script was written for MacOSX only, sorry!"
    exit
fi

#Temporarily Fixing the PATH
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/Applications/Server.app/Contents/ServerRoot/usr/sbin/

#Clu: Flynn! Am I still to create the perfect system?
echo CLU is working on making the perfect system

#removing default files
sudo sharing -r "deploy's Public Folder"
sudo sharing -r "server user's Public Folder"
sudo sharing -r "Temp Admin's Public Folder" 

#adding desired files
sudo sharing -a /Store\ Server\ Images/ -S "Store Server Images" 
sudo sharing -a /Store\ Server\ Images/ -A "Store Server Images" 

#change  set user permissions
sudo chown -R serveruser:staff "/Store Server Images/"
sudo chgrp -R staff "/Store Server Images/"
sudo chmod -R 644 "/Store Server Images/" 

#Enabling services first
sudo serveradmin start caching
sudo serveradmin start web
sudo serveradmin start afp 
sudo serveradmin start smb 

#Opens Server
open -a Server 

#close the script
osascript -e 'tell application "Terminal" to quit'
