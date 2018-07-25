# Based on the article https://relutiondev.wordpress.com/2016/01/09/installing-nodejs-and-npm-kaliubuntu/

# Warning message to user
echo "Use this script if the npm_install does not work"
read answer #fix later

# Make our directory to keep it all in
mkdir  /tmp/local

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
