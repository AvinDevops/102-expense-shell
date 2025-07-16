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

#reading password
echo "please enter db password:"
read mysql_root_password

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

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Disabling nodejs 18v"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs 20v"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then    
    useradd expense &>>$LOGFILE
    VALIDATE $? "creating user expense"
else
    echo  -e "expense user already created... $Y SKIPPING $N"
fi

mkdir /app

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend tom tmp"

cd /app

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "unzipping backend in app dir"

npm install &>>$LOGFILE
VALIDATE $? "installing dependencies for nodejs application"

cp /home/ec2-user/102-expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copying backend service to system loc"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "starting backend service"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend service"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"

mysql -h 172.31.90.239 -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "schema loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting backend service"