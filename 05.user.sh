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

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disable Module nodejs"
dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enable module nodejs 20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Install nodejs"

id roboshop &>> $LOG_FILE
if [ $? == 1 ]; then
    
    echo "Create roboshop user...."
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
  else
    echo "Roboshop user already exists.."
fi

rm -rf /app
VALIDATE $? "remove /app Dir if exists"

mkdir -p /app
VALIDATE $? "created directory /app"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>> $LOG_FILE
VALIDATE $? "download user.zip file to tmp Dir"

cd /app
unzip /tmp/user.zip &>> $LOG_FILE
VALIDATE $? "unzip user.zip to /app"

npm install &>> $LOG_FILE
VALIDATE $? "Install dependencies"

cp $WRK_DIR/user.service /etc/systemd/system/
VALIDATE $? "Copy user.service to /etc/systemd/system/"

systemctl daemon-reload
VALIDATE $? "User Service Daemon reload"

systemctl enable user &>> $LOG_FILE
VALIDATE $? "user Service Enabled"

systemctl restart user &>> $LOG_FILE
VALIDATE $? "user Service Started"
