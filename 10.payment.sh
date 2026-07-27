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


dnf install python3 gcc python3-devel -y
VALIDATE $? "Install python"

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


curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "download payment.zip file to tmp Dir"

cd /app 
unzip /tmp/payment.zip
VALIDATE $? "unzip payment.zip to /app"


pip3 install -r requirements.txt
VALIDATE $? "Install requirements"

cp $WRK_DIR/payment.service /etc/systemd/system
VALIDATE $? "Copy payment.service"


systemctl daemon-reload
VALIDATE $? "payment Service Daemon reload"

systemctl enable payment &>> $LOG_FILE
VALIDATE $? "payment Service Enabled"

systemctl restart payment &>> $LOG_FILE
VALIDATE $? "payment Service Started"