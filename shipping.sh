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


dnf install maven -y &>> $LOGFILE
VALIDATE $? "Maven Installation"

id roboshop &>> $LOGFILE

if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "User roboshop already exists ...$Y SKIPPING $NC"
fi 

mkdir -p /app
VALIDATE $? "App directory creation"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip
VALIDATE $? "Downloading shipping app code"

cd /app
unzip -o /tmp/shipping.zip
VALIDATE $? "Uzipping code into app directory"

mvn clean package
VALIDATE $? "Installing dependencies"


mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Moving and renaming jar file"

cp /home/centos/shell_scripting_RS/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying service file into systemd"

systemctl daemon-reload
VALIDATE $? "Daemon reload"

systemctl enable shipping 
VALIDATE $? "Enabling shipping"

systemctl start shipping
VALIDATE $? "service start"

dnf install mysql -y
VALIDATE $? "Installed mysql client"

mysql -h mysql.roboriya.shop -uroot -pRoboShop@1 < /app/schema/shipping.sql 
VALIDATE $? "loading shipping data"

systemctl restart shipping
VALIDATE $? "Restart Shipping"

