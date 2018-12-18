#!/bin/bash
#Author: Gilles Biagomba
#Program: HTTPBoundary.sh
#Description: This script checks a file with URLs to see if they can reached via a curl command.\n
#	      The objective was to test to see if paths to a web server that requires authentication \n
#	      Could be reached from a user who is not authenticated
#	      reference: https://stackoverflow.com/questions/6136022/script-to-get-the-http-status-code-of-a-list-of-urls
# while read LINE; do
#   curl -o /dev/null --silent --head --write-out "%{http_code} $LINE\n" "$LINE"
# done < url-list.txt

# declaring variable
pth=$(pwd)
TodaysDAY=$(date +%m-%d)
TodaysYEAR=$(date +%Y)
wrkpth="$pth/$TodaysYEAR/$TodaysDAY"

# Capturing file from user
links=$1
if [ $links != "$(ls $PWD | grep $links)" ]; then
    echo file does not exist, please enter a valid filename
    echo usage 'HTTPBoundary.sh links.txt'
    exit
fi

echo What is the project name?
read Prj_name

# mkdir -p HEAD GET TRACE POST PUT DELETE PATCH OPTIONS CONNECT
mkdir -p $wrkpth/OUTPUT $wrkpth/PARSED $wrkpth/EVIDENCE

#touch $wrkpth/OUTPUT/HTTP_HEAD_output.txt $wrkpth/OUTPUT/HTTP_GET_output.txt $wrkpth/OUTPUT/HTTP_TRACE_output.txt $wrkpth/OUTPUT/HTTP_POST_output.txt $wrkpth/OUTPUT/HTTP_PUT_output.txt $wrkpth/OUTPUT/HTTP_DELETE_output.txt $wrkpth/OUTPUT/HTTP_PATCH_output.txt $wrkpth/OUTPUT/HTTP_OPTIONS_output.txt $wrkpth/OUTPUT/HTTP_CONNECT_output.txt
for URL in $(cat $links); do
	curl -o /dev/null --silent --head --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_HEAD_output.txt &
	curl -o /dev/null --silent --get --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_GET_output.txt  &
	curl -o /dev/null --silent -X TRACE --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_TRACE_output.txt  &
	curl -o /dev/null --silent -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "param1=value1&param2=value2" --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_POST_output.txt &
	curl -o /dev/null --silent -X PUT -H "Content-Type: application/x-www-form-urlencoded" -d "param1=value1&param2=value2" --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_PUT_output.txt &
	curl -o /dev/null --silent -X DELETE --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_DELETE_output.txt &
	curl -o /dev/null --silent -X PATCH --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_PATCH_output.txt &
	curl -o /dev/null --silent -X OPTIONS --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_OPTIONS_output.txt &
	curl -o /dev/null --silent -X CONNECT --write-out "%{http_code} $URL\n" "$URL" | tee -a $wrkpth/OUTPUT/HTTP_CONNECT_output.txt &
	wait
done

# HTTPCODE=($(cat HTTP_*_output.txt | cut -d " " -f 1 | sort | uniq))
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 000 | sort > $wrkpth/PARSED/HTTP_Code_DISCONNECT
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 200 | sort > $wrkpth/PARSED/HTTP_Code_OK
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 301 | sort > $wrkpth/PARSED/HTTP_Code_MOVED
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 400 | sort > $wrkpth/PARSED/HTTP_Code_BADREQ
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 401 | sort > $wrkpth/PARSED/HTTP_Code_UNAUTH
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 404 | sort > $wrkpth/PARSED/HTTP_Code_NOTFOUND
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 405 | sort > $wrkpth/PARSED/HTTP_Code_NOTALLOWED
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 411 | sort > $wrkpth/PARSED/HTTP_Code_LNREQ
cat $wrkpth/OUTPUT/HTTP_*_output.txt | grep 502 | sort > $wrkpth/PARSED/HTTP_Code_BADGATE
cat $wrkpth/OUTPUT/HTTP_*_output.txt | sort | uniq > $wrkpth/PARSED/HTTP_Combined

# Fetching Successful downloadeds
cd $wrkpth/EVIDENCE
for URL in $(cat $wrkpth/PARSED/HTTP_Code_OK | cut -d " " -f 2);do
	wget -bpk $URL
	cutycapt --url=$URL --out=$URL.jpg --insecure --max-wait=1000 &
	wait
done

# Zipping up findings
cd $pth
zip -ru -9 $Prj_name-HTTPBoundary.zip $wrkpth/*

# Empty file cleanup
find $wrkpth/ -size 0c -type f -exec rm -rf {} \;

# Uninitializing variables
unset pth
unset TodaysDAY
unset TodaysYEAR
unset URL
unset wrkpth
set -u
