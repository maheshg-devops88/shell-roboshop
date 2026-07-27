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

dnf module disable nginx -y
VALIDATE $? "Disable module nginx"
dnf module enable nginx:1.24 -y
VALIDATE $? "Enable module nginx"
dnf install nginx -y
VALIDATE $? "Install nginx"

systemctl enable nginx 
VALIDATE $? "Enable service nginx"
systemctl start nginx 
VALIDATE $? "Start service nginx"

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "Remove default html file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "download frontend.zip file to tmp Dir"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATE $? "unzip frontend.zip to /app"


rm -rf /etc/nginx/nginx.conf
VALIDATE $? "Remove nginx.conf file"

cp $WRK_DIR/nginx.conf /etc/nginx/
VALIDATE $? "Copy nginx.conf file to /etc/nginx/"

systemctl restart nginx 
VALIDATE $? "Restart nginx Service"
