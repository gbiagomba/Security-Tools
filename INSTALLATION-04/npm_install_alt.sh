#!/usr/bin/env bash
# Based on the article https://relutiondev.wordpress.com/2016/01/09/installing-nodejs-and-npm-kaliubuntu/

# Checking user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Ensuring system is debian based
OS_CHK=$(cat /etc/os-release | grep -o debian)
if [ "$OS_CHK" != "debian" ]; then
    echo "Unfortunately this install script was written for debian based distributions only, sorry!"
    exit
fi

# Warning message to user
echo "Use this script if the npm_install does not work"
read answer #fix later

# Make our directory to keep it all in
src=$(mktemp -d) && cd $src

# Add the location to our path so that we can call it with bash
echo ‘export PATH=$HOME/local/bin:$PATH’ >> ~/.bashrc

# Now we can start with downloading NodeJs and NPM
git clone git://github.com/nodejs/node.git
git clone git://github.com/npm/npm.git

# Compiling NodeJS
cd node
bash configure –-prefix=~/local
make install
cd ../

# Now Compiling NPM (Node Package Manager)
cd npm
make install
cd ../

#Testing our installation
node –version
npm -v
