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

dnf install https://rpms.remirepo.net/enterprise/remi-release-8.8.rpm -y  #error in daws76s - add 8.8. 

VALIDATE $? "installing remi release"

dnf module enable redis:remi-6.2 -y &>>$LOG_FILE

VALIDATE $? "enabling redis: remi - 6.2"

dnf install redis -y &>>$LOG_FILE

VALIDATE $? "installing redis"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>>$LOG_FILE

VALIDATE $? "replacing with 0.0.0.0"

systemctl enable redis &>>$LOG_FILE

VALIDATE $? "enabling redis"

systemctl start redis &>>$LOG_FILE

VALIDATE $? "starting redis"