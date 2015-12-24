#!/bin/bash
# function: 通过ssh实现数据库的在线迁移,从本机迁移到远程数据库,适合只迁移数据库基本结构的情形
#           完全迁移
# author: kfeng
# date: 20151223

# Local Database info
LDB_USER="nercms"
LDB_PASS="123456"

# 代表迁移的数据库列表,以空格进行分隔
DB="enNercms db2"

# Remote Database info
RDB_USER="rot"
RDB_PASS="y1ai"

# Remote Server info
user="bs"
ip="20.14.6.0"
pass='lo#$#' #建议提前设置ssh无密码登录
port="8"

# TODO Checking infomation

echo -n "Checking command mysqldump......"
type mysqldump &> /dev/null && echo "Pass" || { echo "mysqldump is not installed!";exit 1; }
echo -n "Checking command ssh......"
type ssh &> /dev/null && echo "Pass" || { echo "ssh is not installed!";exit 1; }

echo -n "Checking Local Mysql info......"
mysql -u$LDB_USER -p$LDB_PASS -e "" &> /dev/null && echo "Pass" || { echo "Bad Local mysql username or passwd! Exit!"; exit 1; }

for database in $DB
do
    echo -n "Checking DB \"$database\"......"
    mysql -u$LDB_USER -p$LDB_PASS $database -e "" &> /dev/null && echo "Pass" || { echo "Not Exists";exit 1; }
done

echo -n "Checking Remote Server info......"
ssh -p $port $user@$ip date &> /dev/null && echo "Pass" || { echo "Bad Remote Server info! EXit!";exit 1; }
echo -n "Checking Remote Mysql info......"
ssh -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS -e ' '" &> /dev/null && echo "Pass" || { echo "Bad Remote mysql username or passwd! EXit!";exit 1; }

# TODO Migration 
for database in $DB
do
    echo "***************************************"
    # 先在远程机器上创建对应数据库
    echo "Create DB \"$database\" on the Remote Server!"
    # echo "create database $database" | ssh -C -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS"
    echo "drop database if exists $database; create database $database;" | ssh -C -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS" 

    # Migrating from local to remote 
    echo "Migrating DB \"$database\"......"
    # --no-data 只导出数据表结构而不导出数据
    mysqldump --extended-insert --add-drop-table --add-drop-database --lock-tables --force --log-error=error.log \
        -u$LDB_USER -p$LDB_PASS $database | \
        ssh -C -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS $database"

    echo "DB \"$database\" Migration Completed!"
done

echo "***************************************"

