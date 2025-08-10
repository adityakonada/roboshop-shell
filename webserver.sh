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

dnf install nginx -y &>> $LOG_FILE

VALIDATE $? "Installing Nginx"

systemctl enable nginx &>> $LOG_FILE

VALIDATE $? "enabling Nginx"

systemctl start nginx &>> $LOG_FILE

VALIDATE $? "starting Nginx"

rm -rf /usr/share/nginx/html/* &>> $LOG_FILE

VALIDATE $? "deleting default page"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOG_FILE

VALIDATE $? "downloading roboshop webpage"

cd /usr/share/nginx/html &>> $LOG_FILE

VALIDATE $? "cd nginx/html"

unzip /tmp/web.zip &>> $LOG_FILE

VALIDATE $? "unzipping"

cp /home/centos/roboshop-shell/roboshop.config /etc/nginx/default.d/roboshop.conf &>> $LOG_FILE

VALIDATE $? "copying config file"

systemctl restart nginx &>> $LOG_FILE

VALIDATE $? "restarting Nginx"