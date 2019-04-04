# Based on these two articles
# https://medium.com/@airman604/installing-docker-in-kali-linux-2017-1-fbaa4d1447fe
# https://docs.docker.com/install/linux/docker-ce/debian/

# Add Docker PGP key:
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

# Configure Docker APT repository (Kali is based on Debian testing, which will be called buster upon release, and Docker now has support for it):
echo 'deb [arch=amd64] https://download.docker.com/linux/debian buster stable' > /etc/apt/sources.list.d/docker.list

# Update APT:
apt-get update

# Uninstall older docker
apt-get remove docker docker-engine docker.io -y

# Install Docker:
apt-get install docker-ce docker-ce-cli containerd.io -y
