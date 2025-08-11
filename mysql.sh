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

dnf module disable mysql -y &>> $LOG_FILE

VALIDATE $? "disabling mysql"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOG_FILE

VALIDATE $? "copying mysql.repo file"

dnf install mysql-community-server -y &>> $LOG_FILE

VALIDATE $? "installing mysql-community-server"

systemctl enable mysqld &>> $LOG_FILE

VALIDATE $? "enabling mysql"

systemctl start mysqld &>> $LOG_FILE

VALIDATE $? "starting mysql"
 
mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOG_FILE

VALIDATE $? "setting root password"
