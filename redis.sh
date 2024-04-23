#!/bin/bash
ID=$(id -u)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOGFILE="/tmp/$0_$TIMESTAMP.log"
REDIS_CONF="/etc/redis/redis.conf"
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
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
VALIDATE $? "creating redis repository"
dnf module enable redis:remi-6.2 -y &>> $LOGFILE
VALIDATE $? "enabling redis module"
dnf install redis -y &>> $LOGFILE
VALIDATE $? "installing redis"
sed -i 's/127.0.0.1/0.0.0.0/g' $REDIS_CONF &>> $LOGFILE
VALIDATE $? "changing to all access for redis"
systemctl enable redis &>> $LOGFILE
VALIDATE $? "enabling redis"
systemctl start redis &>> $LOGFILE
VALIDATE $? "starting redis"
