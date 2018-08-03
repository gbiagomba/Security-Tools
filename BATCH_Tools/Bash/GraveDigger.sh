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

# Updating the file databse
updatedb

# Locating the fie(s) in question
if [ -z $FILTER ]; then
	FILES=($(locate *.$FTYPE))
else
	FILES=($(locate *.$FTYPE | grep -i $FILTER))
fi

# Zipping up said files
for FILE in ${FILES[*]}; do
	zip -ru -9 $pth/$ZFILE $FILE
done

# CLeaning up
unset pth
unset FTYPE
unset FILTER
unset ZFILE
unset FILES
unset FILE
set -u
