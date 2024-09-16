#!/bin/bash

user_id=$(id -u)

R='\e[31m'
G='\e[32m'
Y="\e[33m"
NC="\e[0m"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R FAILED $NC"
        exit 1
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
VALIDATE $? "Disabling current node js"

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling nodejs:18"

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Nodejs Installation"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "User roboshop already exists ...$Y SKIPPING $NC"
fi 

mkdir -p /app
VALIDATE $? "Application directory creation"

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> $LOGFILE
VALIDATE $? "Application download "

cd /app
unzip -o /tmp/user.zip  &>> $LOGFILE
VALIDATE $? "Unzipping user"

cd /app
npm install 
VALIDATE $? "Installing Dependencies"


cp /home/centos/shell_scripting_RS/user.service /etc/systemd/system/user.service
VALIDATE $? "user service file copied"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "daemon reload"


systemctl enable user &>> $LOGFILE
VALIDATE $? "user service enabled"

systemctl start user &>> $LOGFILE
VALIDATE $? "user service started"

cp /home/centos/shell_scripting_RS/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "mongo repo copied"


dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "Nodejs Installation"


mongo --host mongodb.roboriya.shop </app/schema/user.js &>> $LOGFILE
VALIDATE $? "Loading  user data into MongoDB"
