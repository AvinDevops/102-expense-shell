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

#configuring main steps
dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabiling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing all files ins html dir"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend zip file in tmp dir"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "Changing to html dir"

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Unzipping frontend zip file in html dir"

cp /home/ec2-user/102-expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copying expense.conf to default dir"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx service"