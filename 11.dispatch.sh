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


dnf install golang -y
VALIDATE $? "Install golang"

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

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip  &>> $LOG_FILE
VALIDATE $? "download user.zip file to tmp Dir"

cd /app
unzip /tmp/dispatch.zip &>> $LOG_FILE
VALIDATE $? "unzip dispatch.zip to /app"

go mod init dispatch
go get 
go build


cp $WRK_DIR/dispatch.service /etc/systemd/system
VALIDATE $? "Copy dispatch.service"

systemctl daemon-reload
VALIDATE $? "dispatch Service Daemon reload"

systemctl enable dispatch &>> $LOG_FILE
VALIDATE $? "dispatch Service Enabled"

systemctl restart dispatch &>> $LOG_FILE
VALIDATE $? "dispatch Service Started"

