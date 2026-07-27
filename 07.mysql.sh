#!/bin/bash

cartid=$(id -u)
LOG_FOLDER=/var/log/shell-roboshop
LOG_FILE=/var/log/shell-roboshop/$0.log
WRK_DIR=$PWD

if [ $cartid -ne 0 ]; then
    
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


dnf install mysql-server -y
VALIDATE $? "Install mysql-server"

systemctl enable mysqld
VALIDATE $? "Enable mysqld service"

systemctl start mysqld 
VALIDATE $? "Start mysqld service"

mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Change sql root password"