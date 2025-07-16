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

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql-server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling mysql-server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysql server"

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "Setting root password"