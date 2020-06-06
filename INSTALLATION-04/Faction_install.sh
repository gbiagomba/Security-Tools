#!/usr/bin/env bash
# https://howto.thec2matrix.com/c2/factionc2

curl https://raw.githubusercontent.com/FactionC2/Faction/master/install.sh | sudo bash
sudo faction setup
sudo /opt/apfell/stop_apfell.sh
sudo service postgresql stop
sudo faction start
