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
VALIDATE $? "Disabled nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enable nodejs:20"

dnf install nodejs -y &>> $LOG_FILE
VALIDATE $? "Install nodejs"

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $LOG_FILE
VALIDATE $? "roboshop user added"

mkdir -p /app
VALIDATE $? "created directory /app"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>> $LOG_FILE
VALIDATE $? "downloade catalogue.zip file to tmp Dir"

cd /app
unzip /tmp/catalogue.zip &>> $LOG_FILE
VALIDATE $? "unzip catalogue.zip to /app"

npm install &>> $LOG_FILE
VALIDATE $? "Install dependencies"

cp $WRK_DIR/catalogue.service /etc/systemd/system/
VALIDATE $? "Copy Catalogue.service to /etc/systemd/system/"

systemctl daemon-reload &>> $LOG_FILE
VALIDATE $? "Daemon reload"

systemctl enable catalogue &>> $LOG_FILE
VALIDATE $? "Catalogue Service Enabled"

systemctl start catalogue &>> $LOG_FILE
VALIDATE $? "Catalogue Service Started"

cp mongo.repo /etc/yum.repos.d/
VALIDATE $? "Copy Mongo Process"

dnf install mongodb-org -y  &>> $LOG_FILE
VALIDATE $? "mongodb Installation"