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


dnf install mysql-server -y  &>> $LOG_FILE
VALIDATE $? "Install mysql-server"

systemctl enable mysqld  &>> $LOG_FILE
VALIDATE $? "Enable mysqld service"

systemctl start mysqld &>> $LOG_FILE
VALIDATE $? "Start mysqld service"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE
VALIDATE $? "Change sql root password"