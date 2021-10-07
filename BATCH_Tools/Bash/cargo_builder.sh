#!/usr/bin/env bash
# Author: Gilles Biagomba
# Program: cargo_builder.sh
# Description: This script is designed to automate the building of rust projects

# Ask user for project name
echo "Whats the name of the new cargo project?" 
read prj_name 

if [ -z $prj_name ]; then echo "You did not specify a project name"; exit; fi

# Creating
cargo new $prj_name --bin
open -a "VSCOdium" $prj_name/
cd $prj_name/

