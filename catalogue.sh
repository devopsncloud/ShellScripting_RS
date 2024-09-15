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

dnf module disable nodejs -y &>> $LOGFILE

dnf module enable nodejs:18 -y &>> $LOGFILE

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Nodejs Installation"

useradd roboshop 
VALIDATE $? "roboshop user created"

mkdir /app
VALIDATE $? "Application directory creation"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Application download "

cd /app

unzip /tmp/catalogue.zip &>> $LOGFILE

cd /app

npm install 
VALIDATE $? "Installing Dependencies"





