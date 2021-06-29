#! /usr/bin/env bash
# https://github.com/byt3bl33d3r/CrackMapExec

# Checking if the user is root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# installing package
if pip && pipenv; then
  pip install --user pipenv
  pipenv install crackmapexec
  pipenv run crackmapexec
else
  echo "install pip (your_package-manager install python3-pip) and/or pipenv (pip3 install pipenv)first then try against"
fi

