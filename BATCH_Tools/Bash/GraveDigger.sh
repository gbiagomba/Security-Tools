# Author: Gilles Biagomba
# Program: GraveDigger.sh
# Description: This script was designed to mass copy files and zip them.\n

# Setting working directory
pth=$(pwd)

# Prompting user for questions
echo "What filetype are you trying to ind?"
read FTYPE
echo "What is keyword/filter you would like to use in your search?"
read FILTER
echo "What is the name of the zip file you would like to use?"
read ZFILE
echo "What is the password for the zip file?"
read ZPSS

# Updating the file databse
echo "Seat tight, I am updating you file database (i.e., updatedb)"
updatedb

# Locating the fie(s) in question
echo "Locating your files....hang in there, we are almost done"
if [ -z $FILTER ]; then
	FILES=($(locate *.$FTYPE))
else
	FILES=($(locate *.$FTYPE | grep -i $FILTER))
fi

# Zipping up said files
echo "See patience pays off! Compressing your files now!"
for FILE in ${FILES[*]}; do
	echo "Compressing $FILE"
	zip --password $ZPSS -ru -9 $pth/$ZFILE.zip $FILE
done

# CLeaning up
unset pth
unset FTYPE
unset FILTER
unset ZFILE
unset FILES
unset FILE
unset ZPSS
set -u
