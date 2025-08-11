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

dnf install maven -y &>> $LOG_FILE

VALIDATE $? "installing maven"

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then 
    useradd roboshop &>>$LOG_FILE
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exists.. so $Y Skipping $N"
fi 


mkdir -p /app &>> $LOG_FILE

VALIDATE $? " creating app directory"

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOG_FILE

VALIDATE $? " downloading shipping application - shipping.zip"

cd /app &>> $LOG_FILE

VALIDATE $? " cd app"

unzip -o /tmp/shipping.zip &>> $LOG_FILE

VALIDATE $? " unzipping shipping.zip"

cd /app &>> $LOG_FILE

VALIDATE $? " cd app"

mvn clean package &>> $LOG_FILE

VALIDATE $? " downloading mvn dependencies"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE

VALIDATE $? " renaming jar file"

cp home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service 

VALIDATE $? " copying shipping service"

systemctl daemon-reload &>> $LOG_FILE

VALIDATE $? " daemon reloading"

systemctl enable shipping &>> $LOG_FILE

VALIDATE $? " enabling shipping service"

systemctl start shipping &>> $LOG_FILE

VALIDATE $? " starting shipping service"

dnf install mysql -y &>> $LOG_FILE

VALIDATE $? " installing mysql client "

mysql -h mysql.adityakonada.site -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOG_FILE

VALIDATE $? " loading shipping data"

systemctl restart shipping &>> $LOG_FILE

VALIDATE $? " restarting shipping service"