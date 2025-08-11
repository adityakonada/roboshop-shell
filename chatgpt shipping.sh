#!/bin/bash
ID=$(id -u)

TIMESTAMP=$(date +%F-%H-%M-%S)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOG_FILE="/tmp/$(basename $0)-$TIMESTAMP.log"

echo "Script started executing at $TIMESTAMP" &>> "$LOG_FILE"

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 ..... ${R}error${N}"
        exit 1
    else
        echo -e "$2 ...... ${G}success${N}"
    fi
}

if [ $ID -ne 0 ]; then
    echo -e "You are ${R}not root user${N}. Please run script with root privileges."
    exit 1
else
    echo -e "${G}You are root user${N}"
fi

dnf install maven -y &>> "$LOG_FILE"
VALIDATE $? "Installing maven"

id roboshop &>> "$LOG_FILE"
if [ $? -ne 0 ]; then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "Roboshop user creation"
else
    echo -e "Roboshop user already exists.. so ${Y}Skipping${N}"
fi 

mkdir -p /app/db &>> "$LOG_FILE"
VALIDATE $? "Creating /app/db directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>> "$LOG_FILE"
VALIDATE $? "Downloading shipping application - shipping.zip"

cd /app &>> "$LOG_FILE"
VALIDATE $? "Changing directory to /app"

unzip -o /tmp/shipping.zip &>> "$LOG_FILE"
VALIDATE $? "Unzipping shipping.zip"

mvn clean package &>> "$LOG_FILE"
VALIDATE $? "Building shipping app with maven"

mv target/shipping-1.0.jar shipping.jar &>> "$LOG_FILE"
VALIDATE $? "Renaming jar file"

cp /home/centos/roboshop-shell/shipping.service /etc/systemd/system/shipping.service &>> "$LOG_FILE"
VALIDATE $? "Copying shipping service file"

# Download correct shipping schema from GitHub
curl -L -o /app/db/shipping.sql https://raw.githubusercontent.com/roboshop-devops-project/roboshop-sql/main/shipping.sql &>> "$LOG_FILE"
VALIDATE $? "Downloading shipping schema.sql"

# Validate downloaded SQL file to avoid loading error pages
if head -1 /app/db/shipping.sql | grep -iqE "<?xml|<!DOCTYPE|<html"; then
    echo -e "${R}Downloaded shipping.sql file is invalid (contains HTML/XML). Aborting.${N}"
    exit 1
fi

# Fix ownership so roboshop user can access app files
chown -R roboshop:roboshop /app

systemctl daemon-reload &>> "$LOG_FILE"
VALIDATE $? "Daemon reloading"

systemctl enable shipping &>> "$LOG_FILE"
VALIDATE $? "Enabling shipping service"

systemctl start shipping &>> "$LOG_FILE"
VALIDATE $? "Starting shipping service"

dnf install mysql -y &>> "$LOG_FILE"
VALIDATE $? "Installing mysql client"

# Load shipping schema into MySQL
mysql -h mysql.adityakonada.site -uroot -pRoboShop@1 < /app/db/shipping.sql &>> "$LOG_FILE"
VALIDATE $? "Loading shipping schema into MySQL"

systemctl restart shipping &>> "$LOG_FILE"
VALIDATE $? "Restarting shipping service"
