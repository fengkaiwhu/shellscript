#!/bin/bash

if [ $UID -ne 0 ]; then
	echo "root privilege required, please use SUDO"
	exit
fi

SERVERROOT=/usr/local/server

$SERVERROOT/nginx/sbin/nginx
$SERVERROOT/php/sbin/php-fpm 
#sh /home/erazer/program/mongodb-linux-x86_64-3.0.5/bin/startMongoDB.sh 
