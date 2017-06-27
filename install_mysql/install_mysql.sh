#!/bin/bash

BASEDIR=/tmp/mysql
VERSION=5.7.10
LOGFILE=/tmp/install_mysql.log
#mysql本地下载好的相关源码目录,如果没有,将会从官网下载
SOURCEDIR=/data/mysql/source/
#mysql配置文件,启动脚本目录
MYSQL_CONF_DIR=/data/mysql/conf/

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


function installMysql()
{
    logToFile "|--> Install Mysql Server..."
    cd ${BASEDIR} 
	#基本类库
	yum -y install tar curl-devel cmake gcc gcc-c++ perl-Data-Dumper libaio git perl bison ncurses-devel
    if [ ! -f mysql-5.7.10-linux-glibc2.5-x86_64.tar.gz ]; then
        if [ -f ${SOURCEDIR}mysql-5.7.10-linux-glibc2.5-x86_64.tar.gz ]; then
            cp ${SOURCEDIR}mysql-5.7.10-linux-glibc2.5-x86_64.tar.gz . >> ${LOGFILE} 2>&1
        else
            wget -c http://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-5.7.10-linux-glibc2.5-x86_64.tar.gz >> ${LOGFILE} 2>&1
        fi
        checkRetval 'download mysql-5.7.10-linux-glibc2.5-x86_64.tar.gz'
    fi

    tar zxf mysql-5.7.10-linux-glibc2.5-x86_64.tar.gz >> ${LOGFILE} 2>&1
	cp -r mysql-5.7.10-linux-glibc2.5-x86_64/ /usr/local/mysql/
	cd ..
	rm -rf ${BASEDIR}
    checkRetval 'install mysql successfully'
}

function environment()
{
    echo "|--> Mysql environment: "
	groupadd mysql;
	useradd -g mysql -s /bin/false mysql
    
	cd /usr/local/mysql/
	cp support-files/my-default.cnf /usr/local/mysql/my.cnf
	cp support-files/mysql.server /etc/init.d/mysql
	chmod +x /etc/init.d/mysql
	chkconfig mysql on

	[ -f ${MYSQL_CONF_DIR}my.cnf ] && cp -rf ${MYSQL_CONF_DIR}my.cnf /usr/local/mysql/my.cnf >> ${LOGFILE} 2>&1
	#生成root临时密码
	#bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql > /tmp/install_log
	#不生成root临时密码,需要手动修改密码
	bin/mysqld --initialize-insecure --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --user=mysql > /tmp/install_log
	/etc/init.d/mysql start
	#环境变量
	ln -s /usr/local/mysql/bin/mysql /usr/bin/mysql
	mysql -uroot -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';CREATE USER 'test'@'localhost' IDENTIFIED BY 'test123' PASSWORD EXPIRE NEVER;"
	
	echo "|--> End Mysql environment: "
}

function main()
{
    installMysql
    environment
}

main
