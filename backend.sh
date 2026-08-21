#!/bin/bash

#fetching user,timestamp,scriptname,and creating logfile
USER=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

#Creating colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#giving mysql root password at execution time
echo -e "$R please enter you root password: $N"
read MYSQL_ROOT_PASSWORD

#checking root user or not
if [ $USER -ne 0 ]
then
    echo -e "$R you are not root user, please access with root user $N"
    exit
else
    echo -e "$G you are root user $N"
fi

#creating validation function for checking command success or failure
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N"
        exit
    else
        echo -e "$2 is...$G SUCCESS $N"
    fi
}

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Disabiling nodejs 18v"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabiling nodejs 20v"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Creating expense user"
else
    echo -e "user expense already created...$Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "Creating app dir"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading backend zip folder to tmp"

cd /app
rm -rf /app/* &>>$LOGFILE
VALIDATE $? "Removing all files in app dir"

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Unzipping backend file in app dir"

npm install &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/102-expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copying backend service file to system dir"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon reloading"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabiling backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h db.aviexpense.online -uroot -p${MYSQL_ROOT_PASSWORD} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Loading Schema"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"