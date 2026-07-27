#!/bin/bash

userid=$(id -u)
LOG_FOLDER=/var/log/shell-roboshop
LOG_FILE=/var/log/shell-roboshop/$0.log
WRK_DIR=$PWD

if [ $userid -ne 0 ]; then
    
    echo "Please run the script sudo access"
    exit 1
fi 

VALIDATE()
if [ $1 == 0 ]; then
   echo "$2.....Success" 
 else
   echo "$2.....Failure"
fi

mkdir -p $LOG_FOLDER
VALIDATE $? "LOG directory creation "

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disable redis Module"
dnf module enable redis:7 -y  &>> $LOG_FILE
VALIDATE $? "Enable redis 7 Module"

dnf install redis -y &>> $LOG_FILE
VALIDATE $? "Install redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> $LOG_FILE
VALIDATE $? "Changed address from 127.0.0.1 to 0.0.0.0"


sed -i 's/protected-mode yes/protected-mode no/g' /etc/redis/redis.conf &>> $LOG_FILE
VALIDATE $? "protected-mode from yes to no"

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enable Systemctl service redis"
systemctl start redis &>> $LOG_FILE
VALIDATE $? "Start Systemctl service redis"