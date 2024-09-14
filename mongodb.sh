#!/bin/bash

user_id=$(id -u)

R='\e[31m'
G='\e[32m'
Y="\e[33m"
NC="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "Installation FAILED"
    else
        echo "$2 ... SUCCESS"
    fi 
}


TIMESTAMP=$(date +%d-%m-%Y::%h:%m:%s)
LOGFILE="/tmp/$?-$TIMESTAMP.log"

if [ $user_id -ne 0 ]
then
    echo "You need to be a ROOT user"
    exit 1
else
    echo "Thanks for being root"
fi


cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied Mongdb repo"

