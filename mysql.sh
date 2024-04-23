#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="/tmp/$0_$TIMESTAMP.log"
MONGOD_CONF="/etc/mongod.conf"
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo -e "$RED Error: $2 failed $NORMAL"
      exit 1
    else
      echo -e "$GREEN: $2 success $NORMAL"
    fi
}
if [ $ID -ne 0 ]
then
echo -e "$RED ERROR: please use root access" 
else
echo "root user"
fi
dnf module disable mysql -y &>>$LOGFILE
VALIDATE $? "disabling mysql"
cp  /home/centos/roboshop-shellscript/mysql.repo /etc/yum.repos.d/mysql.repo &>>$LOGFILE
VALIDATE $? "copying mysql repo"
dnf install mysql-community-server -y &>>$LOGFILE
VALIDATE $? "installing mysql"
systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "enabling mysql"
systemctl start mysqld &>>$LOGFILE
VALIDATE $? "starting mysql"
mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE
VALIDATE $? "setting root user password"
mysql -uroot -pRoboShop@1 &>>$LOGFILE
VALIDATE $? "login mysql"