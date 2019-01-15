#!/bin/bash
#Author: Gilles Biagomba
#Program: Git_Cloner.sh
#Description: This script was design to update or clone multiple git repos.\n
# 	          Open the GitLinks.txt file, copy all git links into it.\n
#	          Save and close the file, then run Git_Cloner.sh.\n

#Setting path to working directory
GITPATHTEMP=($(ls -d */ | sort | uniq))
ORGPATH=$(pwd)

#Grabbing file name from the user
GitLinks=$1
if [ $GitLinks != "$(ls $PWD | grep $GitLinks)" ]; then
    echo "$GitLinks does not exist, please enter a valid filename"
    echo "if a file is not specified, default is GitLinks.txt"
    echo usage 'Git_Mngr.sh GitLinks.txt'
    exit
elif [ -z $GitLinks ]; then
    targets=$PWD/GitLinks.txt
fi

#Updating existing git repos
function GitUpdate()
{
    for pths in ${GITPATHTEMP[*]}; do
        cd $ORGPATH/$pths
        echo "----------------------------------------------------------"
        echo "You are updating this Git repo:"
        echo $pths
        echo "----------------------------------------------------------"
        git pull
        cd ..
    done
}

#Downloading new git repos
function GitLinks()
{
    cd $ORGPATH
    # echo  "What is the name of the file with all the git links (Default: GitLinks.txt)?"
    # read GitLinks

    if [ -z $GitLinks ]; then
        GitLinks="GitLinks.txt"
    fi

    for links in $(cat $ORGPATH/$GitLinks);do
        PrjSiteStatus=$(curl -o /dev/null --silent --get --write-out "%{http_code} $links\n" "$links" | cut -d " " -f 1)
        PrjDiskStatus=$(echo $links | cut -d "/" -f 5)
        if [ "$PrjSiteStatus" != "404" ] && [ "$PrjDiskStatus" != "$(ls | grep -o "$PrjDiskStatus")" ]; then
            echo "----------------------------------------------------------"
            echo "You are downloading this Git repo:"
            echo $links
            echo "----------------------------------------------------------"
            git clone $links
        elif [ "$PrjSiteStatus" == "404" ]; then
            echo "$(date +%c): Thhe project $PrjDiskStatus no longer exists or has been moved" | tee -a $ORGPATH/Git_Mngr.log
        elif [ "$PrjDiskStatus" == "$(ls | grep -o "$PrjDiskStatus")" ]; then
            echo "$(date +%c): You have already downloaded the project $PrjDiskStatus before" | tee -a $ORGPATH/Git_Mngr.log
        else
            echo "$(date +%c): If you are reading this, something want EPICLY WRONG.." | tee -a $ORGPATH/Git_Mngr.log
        fi
    done
}

#Pause on exit
function pause()
{
   read -p "$*"
}

#De-initialize all variables & setting them to NULL
function destructor()
{
#    rm $ORGPATH/GITPATHTEMP.txt $ORGPATH/GITPATH.txt -rf
    unset answer
    unset GitLinks
    unset GITPATHTEMP
    unset links
    unset ORGPATH
    unset pths
    unset PrjSiteStatus
    set -u
}

#User selection
function UserSelect()
{
    echo
    echo "What do you want to do?"
    echo "Enter 1 to update existing repos"
    echo "Enter 2 to download new repos"
    echo "Enter 3 to do all of the above"
    echo "Enter 4 to exit"
    read answer
    echo

    if [ "$answer" != "1" ] && [ "$answer" != "2" ] && [ "$answer" != "3" ] && [ "$answer" != "4" ];then
        UserSelect
    fi

    #Switch case
    case $answer in
        1)
            cd $ORGPATH
            GitUpdate            
            UserSelect
            ;;
        2)
            cd $ORGPATH
            GitLinks            
            UserSelect
            ;;
        3)
            cd $ORGPATH
            GitUpdate
            GitLinks            
            UserSelect
            ;;
        4)
            echo "Have a good day"
            pause 'Press [Enter] key to exit...'
            destructor
            clear
            exit
            ;;
    esac
}

UserSelect
