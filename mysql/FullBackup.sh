#!/bin/bash
# function: 备份本地数据库,保存在本地目录
#           完全备份
# author: kfeng
# date: 20151223

# Local Database info
LDB_USER="nercms"
LDB_PASS="123456"

# 代表需要备份的数据库列表,以空格进行分隔
DB="enNercms db2 df4"

# Others vars
BCK_DIR="/tmp/dbbackup"
DATE=`date +%F`

# TODO Checking infomation
echo -n "Checking command mysqldump......"
type mysqldump &> /dev/null && echo "Pass" || { echo "mysqldump is not installed!";exit 1; }

echo -n "Checking command gzip......"
type gzip &> /dev/null && echo "Pass" || { echo "gzip is not installed!";exit 1; }

echo -n "Checking Local Mysql info......"
mysql -u$LDB_USER -p$LDB_PASS -e "" &> /dev/null && echo "Pass" || { echo "Bad mysql username or passwd! Exit!"; exit 1; }

for database in $DB
do
    echo -n "Checking DB \"$database\"......"
    mysql -u$LDB_USER -p$LDB_PASS $database -e "" &> /dev/null && echo "Pass" || { echo "Not Exists";exit 1; }
done

echo -n "Creating Backup dir......"
mkdir -p $BCK_DIR/$DATE/ &> /dev/null && echo "Pass" || { echo "mkdir \"$BCK_DIR/$DATE/\" failed!"; exit 1; }

# 在备份目录中删除7天之前的备份
# find $BCK_DIR -mtime +7 -exec rm -rf {} \;

# TODO full backup 
for database in $DB
do
    echo "***************************************"
    echo "DB \"$database\" being backed up......"
    # --no-data 只导出数据表结构而不导出数据,
    # 如果后续需要进行增量备份,需要 --flush-logs 选项以生成新的二进制文件
    mysqldump --opt --force --flush-logs --log-error=error.log \
        -u$LDB_USER -p$LDB_PASS $database | \
        gzip > $BCK_DIR/$DATE/$database.gz

    echo "DB \"$database\" backup Completed!"
done

echo "***************************************"
