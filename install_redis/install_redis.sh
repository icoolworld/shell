#!/bin/bash

BASEDIR=/tmp/redis
VERSION=3.2.3
LOGFILE=/tmp/install_redis.log
#redis本地下载好的相关源码目录,如果没有,将会从官网下载
SOURCEDIR=/data/redis/source/
#redis配置文件,启动脚本目录
REDIS_CONF_DIR=/data/redis/conf/

[ -f ${LOGFILE} ] && rm -f ${LOGFILE}
[ ! -d ${BASEDIR} ] && mkdir -p ${BASEDIR}

function checkRetval()
{
    val=$?
    echo -n $"$1"
    if [ $val -ne 0 ]
    then
            failure
            echo
            exit 1
    fi
    success
    echo
}

function logToFile()
{
    echo $1
    echo "`date +%Y-%m-%d[%T]` $1" >> ${LOGFILE}
}


function installRedis()
{

    logToFile "|--> Install Redis Server..."
    cd ${BASEDIR} 
    if [ ! -f redis-3.2.3.tar.gz ]; then
        if [ -f ${SOURCEDIR}redis-3.2.3.tar.gz ]; then
            cp ${SOURCEDIR}redis-3.2.3.tar.gz . >> ${LOGFILE} 2>&1
        else
            wget -c http://download.redis.io/releases/redis-3.2.3.tar.gz >> ${LOGFILE} 2>&1
        fi
        checkRetval 'download redis-3.2.3.tar.gz'
    fi

    tar zxf redis-3.2.3.tar.gz >> ${LOGFILE} 2>&1
    cd redis-3.2.3
    make; make install
    #make; make PREFIX=/usr/local/redis install
    checkRetval 'install redis successfully'
}

function environment()
{
    echo "|--> Redis environment: "
    cd ${BASEDIR}
	cd redis-3.2.3
	[ ! -d /etc/redis ] && mkdir -p /etc/redis
	#cp redis.conf /etc/redis/6379.conf
	#sed -i "s#daemonize no#daemonize yes#g" /etc/redis/6379.conf
	#sed -i "s#logfile \"\"#logfile /var/log/redis_6379.log#g" /etc/redis/6379.conf
	#sed -i "s#dir ./#dir /var/lib/redis/6379#g" /etc/redis/6379.conf
	
	#cp utils/redis_init_script /etc/init.d/redis_6379
	#chmod +x /etc/init.d/redis_6379
	#chkconfig redis_6379 on
	#/etc/init.d/redis_6379 start
	sh utils/install_server.sh
	echo "|--> End Redis environment: "
}

function main()
{
    installRedis
    environment
}

main
