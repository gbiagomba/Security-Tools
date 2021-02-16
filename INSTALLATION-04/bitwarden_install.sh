#!/usr/bin/env bash
# Desc: Script to install bitwarden
# ref: https://bitwarden.com/open-source/

curl -Lso bitwarden.sh https://go.btwrdn.co/bw-sh \
  && chmod +x bitwarden.sh
./bitwarden.sh install
./bitwarden.sh start
