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
    cartadd --system --home /app --shell /sbin/nologin --comment "roboshop system cart" roboshop &>> $LOG_FILE
  else
    echo "Roboshop user already exists.."
fi

rm -rf /app
VALIDATE $? "remove /app Dir if exists"

mkdir -p /app
VALIDATE $? "created directory /app"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>> $LOG_FILE
VALIDATE $? "download cart.zip file to tmp Dir"

cd /app
unzip /tmp/cart.zip &>> $LOG_FILE
VALIDATE $? "unzip cart.zip to /app"

npm install &>> $LOG_FILE
VALIDATE $? "Install dependencies"

cp $WRK_DIR/cart.service /etc/systemd/system/
VALIDATE $? "Copy cart.service to /etc/systemd/system/"

systemctl daemon-reload
VALIDATE $? "cart Service Daemon reload"

systemctl enable cart &>> $LOG_FILE
VALIDATE $? "cart Service Enabled"

systemctl restart cart &>> $LOG_FILE
VALIDATE $? "cart Service Started"
