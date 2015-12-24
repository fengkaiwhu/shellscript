#!/bin/bash
#   @charset: utf-8
#   @function: 实现本机到服务器的ssh无密码登录
#   @author: kfeng
#   @date: 2015.12.22

#设置服务器列表文件
ipfile="./ip.txt"

#检测需要的命令是否存在
type ssh-keygen >/dev/null 2>&1 || { echo >&2 "I require ssh-keygen but it's not installed.  Aborting."; exit 1;}
type ssh-copy-id >/dev/null 2>&1 || { echo >&2 "I require ssh-copy-id but it's not installed.  Aborting."; exit 1;}
type expect >/dev/null 2>&1 || { echo >&2 "I require expect but it's not installed.  Aborting."; exit 1;}

#检测文件是否存在
if [ ! -f $ipfile ]; then
    echo >&2 "You must set the ipfile";
    exit 1;
fi

#生成公私秘钥对
cmd1="ssh-keygen -t rsa -f $HOME/.ssh/id_rsa"

expect -c "
    spawn $cmd1;
    expect {
        \"nter passphrase\" {send \"\r\"; exp_continue}
        \"passphrase again\" {send \"\r\"; exp_continue}
        \"save the key\" {send \"\r\"; exp_continue}
        \"verwrite\" {send \"n\r\"; exp_continue}
    }
"

#ssh-add $HOME/.ssh/id_rsa 

#将秘钥对上传至文件列表中的服务器
cat $ipfile | while read line
do
    ip=`echo $line | awk '{print $1}'`
    if [ $ip = "#" ]; then
        continue
    fi
    passwd=`echo $line | awk '{print $2}'`
    username=`echo $line | awk '{print $3}'`
    port=`echo $line | awk '{print $4}'`
    
    #复制公钥文件至服务器
    cmd3="ssh-copy-id -p $port -i $HOME/.ssh/id_rsa.pub $username@$ip"
    expect -c "
        spawn $cmd3;
        expect {
            \"password:\" {send \"$passwd\r\"; exp_continue}
            \"(yes/no)?\" {send \"yes\r\"; exp_continue}
        }
    "
done

echo "Successful!!"
exit 0
