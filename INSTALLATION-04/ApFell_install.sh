#!/usr/bin/env bash
# https://howto.thec2matrix.com/c2/apfell

git clone https://github.com/its-a-feature/Apfell
vim /Apfell/apfell-docker/app/__init__.py
./Apfell/setup_apfell.sh
./start_apfell.sh
./status_check.sh
sudo apfell
