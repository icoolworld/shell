#!/bin/bash

. /etc/init.d/functions
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

#nginx安装日志
LOGFILE=/tmp/install_nginx.log

#nginx版本
VERSION=1.10.1

#源码下载后存储目录
BASEDIR=/tmp/nginx

#nginx源码目录,如果没有,将会从官网下载
SOURCEDIR=/data/nginx/source/

#nginx配置文件,启动脚本目录
NGINX_CONF_DIR=/data/nginx/conf/

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

function logToFile() {
        echo $1
        echo "`date +%Y-%m-%d[%T]` $1" >> ${LOGFILE}
}

function downloadPackage()
{
    echo "|--> Download package: "

	[ ! -d ${BASEDIR} ] && mkdir -p ${BASEDIR}
    cd ${BASEDIR}
    if [ ! -f nginx-${VERSION}.tar.gz ]; then
		if [ -f ${SOURCEDIR}nginx-${VERSION}.tar.gz ]; then
			cp ${SOURCEDIR}nginx-${VERSION}.tar.gz . >> ${LOGFILE} 2>&1
		else
			wget -c http://nginx.org/download/nginx-${VERSION}.tar.gz >> ${LOGFILE} 2>&1
		fi
        checkRetval "download nginx-${VERSION}.tar.gz"
    fi

    if [ ! -f pcre-8.39.tar.gz ]; then
		if [ -f ${SOURCEDIR}pcre-8.39.tar.gz ]; then
			cp ${SOURCEDIR}pcre-8.39.tar.gz . >> ${LOGFILE} 2>&1
		else
			wget -c ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.39.tar.gz >> ${LOGFILE} 2>&1
		fi
        checkRetval 'download pcre-8.39.tar.gz'
    fi
	
	if [ ! -f zlib-1.2.8.tar.gz ]; then
		if [ -f ${SOURCEDIR}zlib-1.2.8.tar.gz ]; then
			cp ${SOURCEDIR}zlib-1.2.8.tar.gz . >> ${LOGFILE} 2>&1
		else
			wget -c http://zlib.net/zlib-1.2.8.tar.gz >> ${LOGFILE} 2>&1
		fi
        checkRetval 'download zlib-1.2.8.tar.gz'
    fi
	
	if [ ! -f openssl-1.0.2h.tar.gz ]; then
		if [ -f ${SOURCEDIR}openssl-1.0.2h.tar.gz ]; then
			cp ${SOURCEDIR}openssl-1.0.2h.tar.gz . >> ${LOGFILE} 2>&1
		else
			wget -c https://www.openssl.org/source/openssl-1.0.2h.tar.gz >> ${LOGFILE} 2>&1
		fi
        checkRetval 'download openssl-1.0.2h.tar.gz'
    fi

}

function installNginx()
{
    echo "|--> Install Nginx: "
    cd ${BASEDIR}
    tar zxf nginx-${VERSION}.tar.gz >> ${LOGFILE} 2>&1
    tar zxf pcre-8.39.tar.gz
	tar zxf zlib-1.2.8.tar.gz
	tar zxf openssl-1.0.2h.tar.gz
    cd nginx-${VERSION}

    # Mark debug mode
    sed -i 's/CFLAGS="$CFLAGS -g"/\#CFLAGS="$CFLAGS -g"/g' auto/cc/gcc >> ${LOGFILE} 2>&1
    # Hide nginx version
    sed -i -e "s/${VERSION}/2.2/g" -e 's/nginx\//Apache\//g' src/core/nginx.h >> ${LOGFILE} 2>&1

	./configure --prefix=/usr/local/nginx-1.10.1 --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre=../pcre-8.39 --with-http_realip_module --with-http_gzip_static_module --with-zlib=../zlib-1.2.8 --with-openssl=../openssl-1.0.2h
    checkRetval 'configure'
    make -j 8 >> ${LOGFILE} 2>&1
    checkRetval 'make'
    make install >> ${LOGFILE} 2>&1
    checkRetval 'make install'
    ln -s /usr/local/nginx-${VERSION} /usr/local/nginx
}

function environment()
{
    echo "|--> environment: "
    [ ! -d /home/wwwroot ] && mkdir -p /home/wwwroot
    [ ! -d /home/weblogs ] && mkdir -p /home/weblogs
    [ ! -d /home/httplogs} ] && mkdir -p /home/httplogs

    cd ${BASEDIR}
	cp ${NGINX_CONF_DIR}nginx.conf . >> ${LOGFILE} 2>&1
	cp ${NGINX_CONF_DIR}test.conf . >> ${LOGFILE} 2>&1
	cp ${NGINX_CONF_DIR}nginx . >> ${LOGFILE} 2>&1

    cp nginx /etc/init.d/nginx
    chmod +x /etc/init.d/nginx
    /sbin/chkconfig --add nginx
	chkconfig nginx on
    checkRetval '/etc/init.d/nginx'

    mv /usr/local/nginx/conf/nginx.conf /usr/local/nginx/conf/nginx.conf.bak
    cp nginx.conf /usr/local/nginx/conf/nginx.conf
    mkdir -p /usr/local/nginx/conf/vhosts
    cp test.conf /usr/local/nginx/conf/vhosts/test.conf

    mkdir /home/wwwroot/test.com/
    echo "<?php phpinfo(); ?>" > /home/wwwroot/test.com/phpinfo.php
    echo "hello~" > /home/wwwroot/test.com/index.html
    chown -R nobody.nobody /home/wwwroot/test.com
    checkRetval 'copy complete'
}

# Run main
function main()
{
    pkill nginx
    rm -rf /etc/init.d/nginx
    rm -rf ${BASEDIR}/*
    rm -rf /usr/local/nginx
    rm -rf /usr/local/nginx-${VERSION}

    [ -f ${LOGFILE} ] && rm -f ${LOGFILE}
    echo "++ start install nginx ++"
    downloadPackage
    installNginx
    environment

    /etc/init.d/nginx start
    #lsof -i:8080

    HOST=`hostname -i`
    echo "Look: http://${HOST}:8080/index.html"
    echo "Look: http://${HOST}:8080/phpinfo.php"

    echo "++ End Install ++"
}


main

