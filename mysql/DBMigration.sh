#!/bin/bash
# function: 通过ssh实现数据库的在线迁移,从本机迁移到远程数据库,适合只迁移数据库基本结构的情形
# author: kfeng
# date: 20151223

# Local Database info
LDB_USER="nercms"
LDB_PASS="123456"

# 代表迁移的数据库列表,以空格进行分隔
DB="enNercms db2"

# Remote Database info
RDB_USER="root"
RDB_PASS="y1nghu@rkai"

# Remote Server info
user="bbs"
ip="202.114.96.30"
pass='logosun!@#$#' #建议提前设置ssh无密码登录
port="8000"

type mysqldump &> /dev/null || { echo "mysqldump is not installed!";exit 1; }

for database in $DB
do
    echo "***************************************"
    # 先在远程机器上创建对应数据库
    echo "Create DB \"$database\" on the Remote Server!"
    # echo "create database $database" | ssh -C -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS"
    echo "drop database if exists $database; create database $database;" | ssh -C -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS" 

    # 接着创建相关的表和数据
    echo "Migrating DB \"$database\"......"
    # --no-data 只导出数据表结构而不导出数据
    mysqldump --extended-insert --add-drop-table --add-drop-database --lock-tables --force --log-error=error.log \
        -u$LDB_USER -p$LDB_PASS $database | \
        ssh -C -p $port $user@$ip "mysql -u$RDB_USER -p$RDB_PASS $database"

    echo "DB \"$database\" Migration Completed!"
done

echo "***************************************"

