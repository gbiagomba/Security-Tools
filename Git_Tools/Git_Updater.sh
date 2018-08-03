#Author: Gilles Biagomba
#Program: Git_Updater.sh
#Description: This script was design to update my Git repo.\n
#	      But you can obviously use it to push changes back\n
#	      in your repo. You do not have anything below\n

git add *
echo "Why are you updating your git profile?"
read comment
git commit -m "$comment"
git push origin master

unset comment