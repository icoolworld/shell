#!/bin/bash

BASEDIR=/tmp/memcached
VERSION=1.4.31
LOGFILE=/tmp/install_memcache.log
#memcached本地下载好的相关源码目录,如果没有,将会从官网下载
SOURCEDIR=/data/memcache/source/
#memcached配置文件,启动脚本目录
MEMCACHED_CONF_DIR=/data/memcache/conf/

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


function installMemcached()
{

    logToFile "|--> Install Memcached Server..."
    cd ${BASEDIR} 
    if [ ! -f libevent-2.0.22-stable.tar.gz ]; then
        if [ -f ${SOURCEDIR}libevent-2.0.22-stable.tar.gz ]; then
            cp ${SOURCEDIR}libevent-2.0.22-stable.tar.gz . >> ${LOGFILE} 2>&1
        else
            wget -c https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz >> ${LOGFILE} 2>&1
        fi
        checkRetval 'download libevent-2.0.22-stable.tar.gz'
    fi

    if [ ! -f memcached-1.4.31.tar.gz ]; then
        if [ -f ${SOURCEDIR}memcached-1.4.31.tar.gz ]; then
            cp ${SOURCEDIR}memcached-1.4.31.tar.gz . >> ${LOGFILE} 2>&1
        else
            wget -c http://www.memcached.org/files/memcached-1.4.31.tar.gz >> ${LOGFILE} 2>&1
        fi
        checkRetval 'download memcached-1.4.31.tar.gz'
    fi

    tar zxf libevent-2.0.22-stable.tar.gz >> ${LOGFILE} 2>&1
    cd libevent-2.0.22-stable
    ./configure --prefix=/usr/local
    make && make install
    ls -al  /usr/local/lib |grep libevent
    checkRetval 'install libevent successfully'

    cd ../
    tar zxf memcached-1.4.31.tar.gz >> ${LOGFILE} 2>&1
    cd memcached-1.4.31
    ./configure --prefix=/usr/local/memcached --with-libevent=/usr/local;
    make; make install
    checkRetval 'install memcached successfully'
}

function environment()
{
    echo "|--> environment: "
    cd ${BASEDIR}
    cp memcached-1.4.31/scripts/memcached.sysv /etc/init.d/memcached
    sed -i "s#/var/run/memcached#/usr/local/memcached/bin/memcached#g" /etc/init.d/memcached
    sed -i "s#daemon memcached#daemon /usr/local/memcached/bin/memcached#g" /etc/init.d/memcached
	chmod +x /etc/init.d/memcached
	chkconfig memcached on
}

function main()
{
    installMemcached
    environment
}

main
