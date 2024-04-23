#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="/tmp/$0_$TIMESTAMP.log"
MONGOD_CONF="/etc/mongod.conf"
RED="\e[31m"
GREEN="\e[31m"
YELLOW="\e[33m"
NORMAL="\e[0m"
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
echo -e "$RED ERROR: please use root access $NORMAL" 
else
echo "root user"
fi
cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "creating mongo repository"
dnf install mongodb-org -y &>> $LOGFILE 
VALIDATE $? "Installing mongoDB"
systemctl enable mongod &>> $LOGFILE
VALIDATE $? "enabling mongoDB service"
systemctl start mongod &>> $LOGFILE
VALIDATE $? "starting mongoDB"
sed -i 's/127.0.0.1/0.0.0.0/g' $MONGOD_CONF &>> $LOGFILE
VALIDATE $? "changing to all access for mongodb"
systemctl restart mongod &>> $LOGFILE
VALIDATE $? "restarting mongoDB"
