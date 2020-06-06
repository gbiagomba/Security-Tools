#!/usr/bin/env bash
# https://howto.thec2matrix.com/c2/koadic

cd /opt/
git clone https://github.com/zerosum0x0/koadic
cd koadic
apt-get install python3-pip
pip3 install -r requirements.txt
sudo koadic
