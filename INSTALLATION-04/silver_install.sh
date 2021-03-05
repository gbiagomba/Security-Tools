#!/usr/bin/env bash
# https://howto.thec2matrix.com/c2/sliver

mkdir /opt/sliver
cd /opt/sliver
wget https://github.com/BishopFox/sliver/releases/download/v0.0.6-alpha/sliver-server_linux.zip
7z x sliver-server_linux.zip
sudo -H /opt/sliver/sliver-server
# apt-get install mingw-w64 binutils-mingw-w64 g++-mingw-w64
