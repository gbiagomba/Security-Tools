#!/usr/bin/env bash
# https://howto.thec2matrix.com/c2/covenant

cd /opt
git clone --recurse-submodules https://github.com/cobbr/Covenant
cd Covenant/Covenant
docker build -t covenant .
docker run -it -p 7443:7443 -p 8080:8080 -p 4433:4433 --name covenant -v /opt/Covenant/Covenant/Data:/app/Data covenant --username AdminUser --computername 0.0.0.0
sudo docker start covenant -ai