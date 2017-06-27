#!/bin/bash

# Source function library.
. /etc/init.d/functions
# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ ${NETWORKING} = "no" ] && exit 0

# Set user PATH
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

LOGS_PATH=/data/httplogs
# Get yesterday date
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d)
# Move file
mv ${LOGS_PATH}/access.log ${LOGS_PATH}/access_${YESTERDAY}.log
kill -USR1 $(cat /var/run/nginx.pid)
