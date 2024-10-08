#!/bin/bash

user_id=$(id -u)

R='\e[31m'
G='\e[32m'
Y="\e[33m"
NC="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R [31m FAILED $NC"
    else
        echo -e "$2 ... $G SUCCESS $NC "
    fi 
}


TIMESTAMP=$(date +%d-%m-%Y::%H:%M:%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

if [ $user_id -ne 0 ]
then
    echo "You need to be a ROOT user"
    exit 1
else
    echo "Thanks for being root"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied Mongdb repo"

dnf install mongodb-org -y &>> $LOGFILE
VALIDATE $? "Installed Mongodb"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabled Mongodb"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Started Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Remote acess to Mongodb"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting  Mongodb"




