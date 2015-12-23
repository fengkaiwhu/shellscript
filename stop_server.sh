#!/bin/zsh

if [ "$UID" -ne 0 ]; then
	echo "root privilege required, please use SUDO"
	exit
fi

SERVERROOT=/usr/local/server

$SERVERROOT/nginx/sbin/nginx -s stop
kill -INT `cat /usr/local/server/php/var/run/php-fpm.pid`
sh /home/erazer/program/mongodb-linux-x86_64-3.0.5/bin/stopMongoDB.sh  
