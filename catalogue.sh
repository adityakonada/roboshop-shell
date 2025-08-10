#!/bin/bash
ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FILE="/tmp/$0-$TIMESTAMP.log" # --> $0 = file_name-date-time.log --> In this format the name of file.log will be stored 

echo "Script started executing at $TIMESTAMP" &>> $LOG_FILE # &>> is rediction concept

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ..... $R error $N"
        exit 1
    else
        echo -e "$2 ...... $G success $N"
    fi
}


if [ $ID -ne 0 ]
then
    echo -e "You are $R not root user $N. Please run script with root access man"
    exit 1 # you are asking program to exit from here, do not process further.
            # You can give any number other than 0
else
     echo -e "$G You are Root user $N"
fi 

dnf module disable nodejs -y &>> $LOG_FILE

VALIDATE $? "disabling nodejs"

dnf module enable nodejs:18 -y &>> $LOG_FILE

VALIDATE $? "enabling nodejs 18"

dnf install nodejs -y &>> $LOG_FILE

VALIDATE $? "Installing nodejs"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then 
    userdd roboshop &>>LOG_FILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exists.. so $Y Skipping $N"
fi 

mkdir -p /app &>> $LOG_FILE #The -p option stands for "parents"No error if the target directory already exists.

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOG_FILE

VALIDATE $? "downloading catalogue zip file"

cd /app &>> $LOG_FILE

VALIDATE $? " cd app"

unzip -o /tmp/catalogue.zip &>> $LOG_FILE #-o means overwrite, so that no error occurs. already error came for me. 

VALIDATE $? "unzipping catalogue.zip"

cd /app &>> $LOG_FILE

VALIDATE $? "cd app"

npm install &>> $LOG_FILE

VALIDATE $? "installing npm dependencies"

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOG_FILE

VALIDATE $? "copying catalogue.service"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? "daemon reloading"

systemctl enable catalogue &>> $LOG_FILE

VALIDATE $? "enabling catalogue"

systemctl start catalogue &>> $LOG_FILE

VALIDATE $? "starting catalogue" 

cp /home/centos/roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE #cp log of mongo.repo(we just created as another file) to req place(given in documentation) to make things work

VALIDATE $? "copying mongo.repo" 

dnf install mongodb-org-shell -y&>> $LOG_FILE

VALIDATE $? "installing mongodb server client" 

mongo --host mongodb.adityakonada.site </app/schema/catalogue.js &>> $LOG_FILE

VALIDATE $? "loading schema - default products" 