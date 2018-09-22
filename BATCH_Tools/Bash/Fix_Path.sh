#Author: Gilles S. Biagomba
#Program: $PATH Fixer
#Description: This program is designed to fix the binary paths. \n

#Move into home directory
cd
#Create the .bash_profile file
touch .bash_profile
#Add in the above line which declares the new location /Applications/Server.app/Contents/ServerRoot/usr/sbin/
echo export PATH="/Applications/Server.app/Contents/ServerRoot/usr/sbin/:$PATH" > .bash_profile
#Adds the original PATH values
echo PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin >> .bash_profile