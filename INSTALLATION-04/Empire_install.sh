#!/usr/bin/env bash
# https://howto.thec2matrix.com/c2/empire

cd /opt
sudo git clone https://github.com/BC-SECURITY/Empire.git
cd Empire
sudo ./setup/install.sh
cd /opt
sudo wget https://github.com/BC-SECURITY/Starkiller/releases/download/v1.0.0/starkiller-1.0.0.AppImage
sudo chmod +x starkiller-1.0.0.AppImage
sudo empire
