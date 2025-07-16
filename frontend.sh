#!/bin/bash

#fetching user details
USERID=$(id -u)
#creating timestamp,scriptname for logs and created logfile
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

#creating colors variables
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#checking root user or not
if [ $USERID -ne 0 ]
then 
    echo -e "$R you are not root user, please access with root user $N"
    exit
else
    echo -e "$G you are root user $N"
fi 

#creating VALIDATE function
VALIDATE() {

    if [ $1 -ne 0 ]
    then
        echo -e "$2....is $R FAILED $N"
        exit
    else
        echo -e "$2....is $G SUCCESS $N"
    fi
}

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "removing old file in html dir"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading frontend"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Unzipping frontend in html dir"

cp /home/ec2-user/102-expense-shell/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "copying expense conf to default.d"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"