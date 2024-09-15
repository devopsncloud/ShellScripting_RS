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
exec &>$LOGFILE

if [ $user_id -ne 0 ]
then
    echo "You need to be a ROOT user"
    exit 1
else
    echo "Thanks for being root"
fi

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "Downloading redis repo"

dnf module enable redis:remi-6.2 -y 
VALIDATE $? "Enabling redis:remi-6.2"

dnf install redis -y 
VALIDATE $? "redis Installation"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf

systemctl enable redis 
VALIDATE $? "redis service enabled"

systemctl start redis 
VALIDATE $? "redis service started"

