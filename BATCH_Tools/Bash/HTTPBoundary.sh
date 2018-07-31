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

# mkdir -p HEAD GET TRACE POST PUT DELETE PATCH OPTIONS CONNECT
mkdir OUTPUT PARSED

echo "What is the name of the target file? (That's the file with all the links)"
read links

#touch OUTPUT/HTTP_HEAD_output.txt OUTPUT/HTTP_GET_output.txt OUTPUT/HTTP_TRACE_output.txt OUTPUT/HTTP_POST_output.txt OUTPUT/HTTP_PUT_output.txt OUTPUT/HTTP_DELETE_output.txt OUTPUT/HTTP_PATCH_output.txt OUTPUT/HTTP_OPTIONS_output.txt OUTPUT/HTTP_CONNECT_output.txt

for URL in $(cat links); do
	curl -o /dev/null --silent --head --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_HEAD_output.txt &
	curl -o /dev/null --silent --get --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_GET_output.txt  &
	curl -o /dev/null --silent -X TRACE --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_TRACE_output.txt  &
	curl -o /dev/null --silent -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "param1=value1&param2=value2" --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_POST_output.txt &
	curl -o /dev/null --silent -X PUT -H "Content-Type: application/x-www-form-urlencoded" -d "param1=value1&param2=value2" --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_PUT_output.txt &
	curl -o /dev/null --silent -X DELETE --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_DELETE_output.txt &
	curl -o /dev/null --silent -X PATCH --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_PATCH_output.txt &
	curl -o /dev/null --silent -X OPTIONS --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_OPTIONS_output.txt &
	curl -o /dev/null --silent -X CONNECT --write-out "%{http_code} $URL\n" "$URL" | tee -a OUTPUT/HTTP_CONNECT_output.txt &
	wait
done

# HTTPCODE=($(cat HTTP_*_output.txt | cut -d " " -f 1 | sort | uniq))
cat OUTPUT/HTTP_*_output.txt | grep 000 | sort > PARSED/HTTP_Code_DISCONNECT
cat OUTPUT/HTTP_*_output.txt | grep 200 | sort > PARSED/HTTP_Code_OK
cat OUTPUT/HTTP_*_output.txt | grep 301 | sort > PARSED/HTTP_Code_MOVED
cat OUTPUT/HTTP_*_output.txt | grep 400 | sort > PARSED/HTTP_Code_BADREQ
cat OUTPUT/HTTP_*_output.txt | grep 401 | sort > PARSED/HTTP_Code_UNAUTH
cat OUTPUT/HTTP_*_output.txt | grep 404 | sort > PARSED/HTTP_Code_NOTFOUND
cat OUTPUT/HTTP_*_output.txt | grep 405 | sort > PARSED/HTTP_Code_NOTALLOWED
cat OUTPUT/HTTP_*_output.txt | grep 411 | sort > PARSED/HTTP_Code_LNREQ
cat OUTPUT/HTTP_*_output.txt | grep 502 | sort > PARSED/HTTP_Code_BADGATE
cat OUTPUT/HTTP_*_output.txt | sort | uniq > PARSED/HTTP_Combined

# Empty file cleanup
find $pth/$wrkpth/ -size 0c -type f -exec rm -rf {} \;

# Uninitializing variables
unset URL
set -u