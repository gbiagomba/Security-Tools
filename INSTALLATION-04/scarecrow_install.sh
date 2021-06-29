#! /usr/bin/env bash
# ref: https://github.com/optiv/ScareCrow

# Checking if the user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# installing package
if go && git; then
  git clone https://github.com/optiv/ScareCrow
  cd ScareCrow
  go get github.com/fatih/color
  go get github.com/yeka/zip
  go get github.com/josephspurrier/goversioninfo
  go get github.com/optiv/ScareCrow
  go install ScareCrow.go
else
  echo "install git or go first then try against"
fi
