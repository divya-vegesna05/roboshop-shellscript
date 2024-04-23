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
dnf install maven -y &>> $LOGFILE
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
curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
VALIDATE $? "downloading application"
cd /app &>> $LOGFILE
VALIDATE $? "changing directory"
unzip -o /tmp/shipping.zip &>> $LOGFILE
VALIDATE $? "Installing application"
cd /app &>> $LOGFILE
VALIDATE $? "changing directory"
mvn clean package &>> $LOGFILE
VALIDATE $? "Installing dependencies"
mv target/shipping-1.0.jar shipping.jar &>> $LOGFILE
VALIDATE $? "moving shipping jr file"
cp /home/centos/roboshop-shellscript/shipping.service /etc/systemd/system/shipping.service &>> $LOGFILE
VALIDATE $? "craeting shipping service"
systemctl enable shipping &>> $LOGFILE
VALIDATE $? "enabling shipping service"
systemctl start shipping &>> $LOGFILE
VALIDATE $? "starting shipping service"
dnf install mysql -y &>> $LOGFILE
VALIDATE $? "install mysql client"
mysql -h mysql.jasritha.tech -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
VALIDATE $? "loading shiipping data"
systemctl restart shipping
VALIDATE $? "restart shipping" &>> $LOGFILE