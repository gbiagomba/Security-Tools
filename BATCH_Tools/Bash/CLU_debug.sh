#!/usr/bin/env bash

#NOTE: THIS IS THE DEBUGGING VERSION, DO NOT RUN THIS UNLESS YOU KNOW WHAT YOU'RE DOING \n
#Author: Gilles S. Biagomba
#Program: Codified Likeness Utility or CLU
#Description: This program is designed to start Server services (caching, web, afp and smb), \n
#contd. remove the default share-point(s) and add the desired share-point. \n
#contd. then it changes the share-point user owner, user group and file permissions \n
#contd. Lastly, it opens the server application so that the user may double check every was done correctly \n

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

#contd. copyright © 2014-2015 David's Bridal Inc. All Rights Reserved.
echo CLU is working on making the perfect system
\n
#Enabling services first
sudo serveradmin start caching
sudo serveradmin start web
sudo serveradmin start afp 
sudo serveradmin start smb 
read -p "Starting the services"
\n
#removing default files
#it looks like DBI is creating 3 users called deploy, serveruser and tempadmin. the -r flag is set to remove the sharepoint name... not the path where the shared data lives.
#to get a list of the sharepoints currently being shared, i'd use sharing -l and pipe those to variables and then remove the variable with no "". 
sudo sharing -r "deploy's Public Folder"
sudo sharing -r "server user's Public Folder"
sudo sharing -r "Temp Admin's Public Folder" 
read -p "Removing default shared files"
\n
#adding desired files
#-a adds the file, "\ " (note the trailing space) escapes the space and -S sets up an SMB sharepoint called 
sudo sharing -a /Store\ Server\ Images/ -S "Store Server Images" 
sudo sharing -a /Store\ Server\ Images/ -A "Store Server Images" 
read -p "Added Server Store Image sharepoint"
\n
#change  set user permissions
sudo chown -R serveruser:staff "/Store Server Images/"
sudo chgrp -R staff "/Store Server Images/"
sudo chmod -R 644 "/Store Server Images/" 
read -p "Changing user name  file permissions"
\n
#Opens Server
open -a Server 
read -p "Starting Server Application"
\n
#close the script
osascript -e 'tell application "Terminal" to quit'
