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
    echo "Thanks for being root \n"
fi

dnf install nginx -y
VALIDATE $? "Nginx Installation"

systemctl enable nginx
VALIDATE $? "Nginx Enable"

systemctl start nginx
VALIDATE $? "Nginx Start"

rm -rf /usr/share/nginx/html/*
VALIDATE $? "Default HTML content cleared"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip
VALIDATE $? "Dowloanding web content"

cd /usr/share/nginx/html
VALIDATE $? "moving to html directory"

unzip -o /tmp/web.zip
VALIDATE $? "Unzipping web content"

cp /home/centos/shell_scripting_RS/roboshop.conf /etc/nginx/default.d/roboshop.conf
VALIDATE $? "Copied roboshop reverse proxy config"

systemctl restart nginx
VALIDATE $? "Nginx restart"
