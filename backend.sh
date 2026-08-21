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
    echo -e "$R you are root user $N"
fi

#creating validation function for checking command success or failure
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is...$R FAILED $N"
        exit
    else
        echo -e "$2 is...$G SUCCESS $N"
}

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Disabiling nodejs 18v"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabiling nodejs 20v"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

useradd expense &>>$LOGFILE
VALIDATE $? "Creating expense user"