#!/bin/bash
# function: 同步本地文件到远程服务器上,可用于服务器端开发
# author: kfeng
# date: 20151223

# some var
# 在下面的例子中,同步之后远程服务器上的文件层次为: /tmp/wwwtest/enNercms/
# 本地同步目录,目录后面不需要 '/'
LDIR="/var/www/enNercms"
# 服务器端同步目录,目录后面不需要 '/'
RDIR="/tmp/wwwtest"

# Remote Server info
user="s"
ip="2.1.6.3"
passwd='l#'
port="80"

# TODO Checking infomation

echo -n "Checking command ssh......"
type ssh &> /dev/null && echo "Pass" || { echo "ssh is not installed!";exit 1; }
echo -n "Checking command rsync......"
type rsync &> /dev/null && echo "Pass" || { echo "rsync is not installed!";exit 1; }

echo -n "Checking local dir \"$LDIR\"......"
[ -d $LDIR ] && echo "Pass" || { echo "Not Exists"; exit 1; }

echo -n "Checking Remote Server info......"
ssh -p $port $user@$ip date &> /dev/null && echo "Pass" || { echo "Bad Remote Server info! EXit!";exit 1; }

echo -n "Checking Remote Dir \"$RDIR\"......"
ssh -p $port $user@$ip "cd $RDIR" &> /dev/null && echo "Pass" || { echo "Bad Remote Dir! EXit!";exit 1; }

echo -n "Transfering data to remote server......"
rsync -arHz --delete -e "ssh -p $port" $LDIR $user@$ip:$RDIR &> /dev/null
echo "Completed!"
