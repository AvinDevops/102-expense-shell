#!/bin/bash

USER=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPTNAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

VALIDATE(){
 if [ $1 -ne 0 ]
 then
    echo -e "$2 is...$R FAILED $N"
    exit
 else
    echo -e "$2 is...$G SUCCESS $N"
 fi   
}

if [ $USER -ne 0 ]
then
    echo -e "$R you are not root user, please access with root $N"
    exit
else
    echo -e "$G you are root user $N"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing mysql"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabiling mysql"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting mysql"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting password for root"
mysql -h db.aviexpense.online -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
    VALIDATE $? "Setting password for root"
else
    echo -e "Password for mysql root user already set...$Y SKIPPING $N"
fi
