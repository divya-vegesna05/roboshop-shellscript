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
dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disable nodejs" 
dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enable nodejs18"
dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing nodejs18"
id roboshop
if [ $? -ne 0 ]
then
useradd roboshop &>> $LOGFILE
VALIDATE $? "Adding roboshop user"
else
echo "roboshop user exists $YELLOW .. skipping"
fi
mkdir -p /app &>> $LOGFILE
VALIDATE $? "creating directory" 
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "downloading application"
cd /app &>> $LOGFILE
VALIDATE $? "changing directory"
unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Installing application"
cd /app &>> $LOGFILE
VALIDATE $? "changing directory"
npm install &>> $LOGFILE
VALIDATE $? "Installing dependencies"
cp /home/centos/roboshop-shellscript/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "creating cart service"
systemctl daemon-reload &>> $LOGFILE
VALIDATE $? "reloading daemon"
systemctl enable cart &>> $LOGFILE
VALIDATE $? "Enabling cart"
systemctl start cart &>> $LOGFILE
VALIDATE $? "starting cart"
