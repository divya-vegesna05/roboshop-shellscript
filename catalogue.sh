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
dnf module disable nodejs -y
VALIDATE $? "disable nodejs"
dnf module enable nodejs:18 -y
VALIDATE $? "Enable nodejs18"
dnf install nodejs -y
VALIDATE $? "Installing nodejs18"
id roboshop
if [ $id -ne 0 ]
then
useradd roboshop
VALIDATE $? "Adding roboshop user"
else
echo "roboshop user exists $YELLOW .. skipping"
fi
mkdir -p /app
VALIDATE $? "creating directory"
curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloading application"
cd /app 
VALIDATE $? "changing directory"
unzip -o /tmp/catalogue.zip
VALIDATE $? "Installing application"
cd /app
VALIDATE $? "changing directory"
npm install 
VALIDATE $? "Installing dependencies"
cp /home/centos/roboshop-shellscript/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "creating catalogue service"
systemctl daemon-reload
VALIDATE $? "reloading daemon"
systemctl enable catalogue
VALIDATE $? "Enabling catalogue"
systemctl start catalogue
VALIDATE $? "starting catalogue"
cp /home/centos/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "creating mongo repo"
dnf install mongodb-org-shell -y
VALIDATE $? "installing mongo client"
mongo --host mongodb.jasritha.tech </app/schema/catalogue.js
VALIDATE $? "loading catalogue products"