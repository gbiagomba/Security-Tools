#Program: GITHTMLParser.sh
#Description: This script was design to pull Git links.\n
#	      out of an HTML file and store it into another file\n

echo "What file would you like to parse gitlinks from?"
read INFILE
echo "What would you like the name of the gitlink repo named?"
read OUTFILE
cat $INFILE | grep -oP  '"\K[^"\047]+(?=["\047])' | grep github > $OUTFILE

