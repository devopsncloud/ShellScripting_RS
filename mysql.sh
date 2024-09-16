
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


dnf module disable mysql -y
VALIDATE $? "Disabling default version of mysql"

cp /home/centos/shell_scripting_RS/mysql.repo  /etc/yum.repos.d/mysql.repo
VALIDATE $? "copying mysql repo into yum.repos.d"

dnf install mysql-community-server -y
VALIDATE $? "MySql server Installation"

systemctl enable mysqld
VALIDATE $? "Enabled mysqld"

systemctl start mysqld
VALIDATE $? "started mysqld"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting MySQL root password"

#mysql -uroot -pRoboShop@1