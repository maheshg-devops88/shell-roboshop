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

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Install maven"

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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> $LOG_FILE
VALIDATE $? "download user.zip file to tmp Dir"

cd /app
unzip /tmp/shipping.zip &>> $LOG_FILE
VALIDATE $? "unzip shipping.zip to /app"

mvn clean package 
VALIDATE $? "mvn to Clean package"

mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "move shipping.jar from target to /app"

cp $WRK_DIR/shipping.service /etc/systemd/system/
VALIDATE $? "Copy shipping.service to /etc/systemd/system/"

systemctl daemon-reload
VALIDATE $? "shipping Service Daemon reload"

systemctl enable shipping &>> $LOG_FILE
VALIDATE $? "shipping Service Enabled"

systemctl start shipping &>> $LOG_FILE
VALIDATE $? "shipping Service Started"

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Install mysql"

# Query the database to check if the schema exists
DB_EXISTS=$(mysql -h mysql.daws88s.shop -uroot -pRoboShop@1 -sN -e "SELECT COUNT(*) FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = 'cities'")

if [ $DB_EXISTS -ne 1 ]; then
    echo "Schema cities does not exist. Running schema.sql..."
    mysql -h mysql.daws88s.shop -uroot -pRoboShop@1 < /app/db/schema.sql  &>> $LOG_FILE
    mysql -h mysql.daws88s.shop -uroot -pRoboShop@1 < /app/db/app-user.sql &>> $LOG_FILE
    mysql -h mysql.daws88s.shop -uroot -pRoboShop@1 < /app/db/master-data.sql &>> $LOG_FILE
else
    echo "Schema cities already exists. Skipping installation."
fi

systemctl restart shipping &>> $LOG_FILE
VALIDATE $? "shipping Service Started"