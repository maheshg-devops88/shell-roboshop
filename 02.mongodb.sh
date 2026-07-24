#!/bin/bash

userid=$(id -u)
LOG_FOLDER=/var/log/shell-roboshop
LOG_FILE=/var/log/shell-roboshop/$0.log

if [ $userid -ne 0 ]; then
    
    echo "Please run the script sudo access"
    exit 1
fi 

VALIDATE()
if [ $1 == 0 ]; then
   echo "$2 is SuccessFul" 
 else
   echo "$2 is Failure"
fi

mkdir -p $LOG_FOLDER
VALIDATE $? "LOG directory creation is"

cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "Copy Process"

dnf install mongodb-org -y  &>> $LOG_FILE
VALIDATE $? "mongodb Installation"

systemctl enable mongod 
VALIDATE $? "mongodb enabled"


sed -i 's/127.0.0.1/0.0.0.0/g'  /etc/mongod.conf  &>> $LOG_FILE
VALIDATE $? "Changing to 127.0.0.1 to 0.0.0.0" 

systemctl start mongod
VALIDATE $? "mongodb service start state"