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
dnf install nginx -y &>> $LOGFILE
VALIDATE $? "Installing nginx"
systemctl enable nginx &>> $LOGFILE
VALIDATE $? "enabling nginx"
systemctl start nginx &>> $LOGFILE
VALIDATE $? "starting nginx"
rm -rf /usr/share/nginx/html/* &>> $LOGFILE
VALIDATE $? "removing default html files"
curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
VALIDATE $? "download application"
cd /usr/share/nginx/html &>> $LOGFILE
VALIDATE $? "changing directory"
unzip -o /tmp/web.zip &>> $LOGFILE
VALIDATE $? "installing application"
cp /home/centos/roboshop-shellscript/roboshop.conf /etc/nginx/default.d/roboshop.conf &>> $LOGFILE
VALIDATE $? "creating ngnix conf file"
systemctl restart nginx &>> $LOGFILE
VALIDATE $? "restarting nginx"