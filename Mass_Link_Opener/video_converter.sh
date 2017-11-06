#!/bin/bash
#Author: Gilles Biagomba
#Program: video_converter.sh
#Description: This script was written to convert webm files to mp4 files.\n
#links: https://youtu.be/NHGZCqRTWgw
#links: http://k4linux.com/2015/09/kali-linux-20-tutorials-convert-video.html
#
for vids in $(cat videos);do
echo "----------------------------------------------------------"
echo "You are downloading G-Drive Link:"
echo $vids
echo "----------------------------------------------------------"
avconv -i "$vids" -c:v libx264 -crf 20 -c:a aac -strict experimental "$vids.mp4"
done

