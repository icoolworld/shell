#!/bin/sh
# mysqld This shell script takes care of starting and stopping
# the MySQL subsystem (mysqld) using mysql_multi.
#
# chkconfig: - 64 36
# description: MySQL database server.
# processname: mysqld
# config: /etc/my.cnf

#put your MySql root pass here with the --password=
#example: pass="--password=ChangeThisPassword"
pass="--password=123456"

mysqld_start() {
echo "Starting mysqld..."
mysqld_multi start $* $pass
}

mysqld_stop() {
echo "Stopping mysqld..."
mysqld_multi stop $* $pass
}

mysqld_restart() {
mysqld_stop $*
sleep 1
mysqld_status $*
sleep 1
mysqld_start $*
sleep 1
mysqld_status $*
}
mysqld_which() {
b=`grep "\[mysqld[0-9][0-9]*\]" /etc/my.cnf | sed 's/[^A-Za-z0-9]//g' | wc -l`
echo "The following $b instances are configured:"
grep "\[mysqld[0-9][0-9]*\]" /etc/my.cnf | sed 's/[^A-Za-z0-9]//g'
}

mysqld_status() {
mysqld_multi report $*
}

#Set these variables so mysqld finds the right information
export PATH=/usr/local/mysql/bin:/usr/bin:/usr/sbin:$PATH
option=$1
shift

case "$option" in
'start') mysqld_start $*;;
'stop') mysqld_stop $*;;
'restart') mysqld_restart $*;;
'which') mysqld_which $*;;
'status')
mysqld_status $* ;;
*)
echo "Usage: $0 [start|stop|restart|status|which]"
echo "Optional info: "
echo " This uses mysql_multi, which allows control of individual mysqld "
echo " instances. Do this by specifying a list of numbers following the"
echo " command (start/stop/etc.). For example:"
echo " $0 stop 1,3"
echo " $0 stop 1-3"
echo " $0 stop 1"
echo " $0 stop 1-3,5"
echo
echo " do $0 which to list the mysql instances that are configured"
esac