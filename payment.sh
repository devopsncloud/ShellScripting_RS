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

dnf install python36 gcc python3-devel -y &>> $LOGFILE
VALIDATE $? "Installing python"

id roboshop &>> $LOGFILE
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "User roboshop already exists ...$Y SKIPPING $NC"
fi 


mkdir /app 
VALIDATE $? "Creating app directory"

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> $LOGFILE
VALIDATE $? "Downloading payment"

cd /app 

unzip -o /tmp/payment.zip &>> $LOGFILE
VALIDATE $? "Unzipping payment installing dependencies"

cd /app 
pip3.6 install -r requirements.txt &>> $LOGFILE
VALIDATE $? "Installing Dependencies"

cp /home/centos/shell_script_RS/payment.service /etc/systemd/system/patment.service &>> $LOGFILE
VALIDATE $? "Copying payment service"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "Daemon-reload"

systemctl enable payment &>> $LOGFILE
VALIDATE $? "Enabling payment"

systemctl start payment &>> $LOGFILE
VALIDATE $? "Starting payment"