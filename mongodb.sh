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

cp mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOG_FILE
# firstly open a new file-mongo.repo in folder, copy the content
#Now command explanation --> copying a file mongo.repo to /etc/yum.repos.d/mongo.repo (copying as same name mongo.repo - last word in cmd)
VALIDATE $? "Copying mongo.repo"

dnf install mongodb-org -y &>> $LOG_FILE
 
VALIDATE $? "Installation of monngo db server"

systemctl enable mongod &>> $LOG_FILE
 
VALIDATE $? "Enabling mongodb"

systemctl start mongod &>> $LOG_FILE
 
VALIDATE $? "Starting mongodb"

sed -e 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE $? "replacing 0.0.0.0"

systemctl restart mongod &>> $LOG_FILE
 
VALIDATE $? "Restarting mongodb"