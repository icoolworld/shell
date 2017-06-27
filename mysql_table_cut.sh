#!/bin/bash
#分表方案,先水平切割,按时间存储

#====mysql config====
source_mysql_host="192.168.1.2"
source_mysql_user=root
source_mysql_pwd=123456
source_mysql_port=3306
source_mysql_db=mydb
#要切割的表
source_mysql_tables="statistic_common"

dist_mysql_host="192.168.1.2"
dist_mysql_user=root
dist_mysql_pwd=123456
dist_mysql_port=3306
dist_mysql_db=mydb
#存储历史数据的表前缀
dist_mysql_tables="statistic_common"

#====mysql bin====
mysql=/usr/local/mysql/bin/mysql
mysqldump=/usr/local/mysql/bin/mysqldump

#每张存档表,存储6个月的数据
save_time=6

#设置切割表的时间字段,按该字段时间切割
cut_table_by_field="access_time"

#日志文件
logfile='/tmp/cut_table_log'


#初始化切割表
function initCutTable() {
    log "init cut table $source_mysql_tables"
    #初始化,切割该年份的表数据,默认当前年份
    year=`date +%Y`
    total_month=12
    length=`expr $total_month / $save_time`
    counter=0
    begin=0
    while [ $counter -lt $length ]
    do
        if [ "$counter" = "0" ]; then
            begin=`expr $begin + 1`
        else
            begin=`expr $begin + $save_time`
        fi
        end=`expr $begin + ${save_time} - 1`
        #存档表名称
        history_table_name="${dist_mysql_tables}_history_${year}_${begin}_${end}";
        start_time=`date -d ${year}-${begin}-1 +%s`
        end_date=`expr $end + 1`
        if [ ${end_date} -gt 12 ]; then
            end_date=`expr ${end_date} - 12`
            year=`expr $year + 1`
        fi
        end_time=`date -d "${year}-${end_date}-1" +%s`
        condition="${cut_table_by_field} >= ${start_time} AND ${cut_table_by_field} < ${end_time}"

        #创建历史存档表,可以一同拷备索引
        querySql "CREATE TABLE ${history_table_name} LIKE ${source_mysql_tables};"
        log "create table $history_table_name success!!!"
        #保存数据
        saveData "${history_table_name}" "${source_mysql_tables}" "${condition}"
        log "save data to table $history_table_name success!!!"
        #saveDataByCreate "${history_table_name}" "${source_mysql_tables}" "${condition}"
        #table_array[$counter]=$history_table_name
        counter=`expr $counter + 1`
    done
    log "init cut table $source_mysql_tables success!!!"
    #echo ${table_array[*]}
}



#增量切割表数据
function incCutTable() {
    log "increament cut table $source_mysql_tables data to $dist_mysql_tables"
    current_date=$(date +%Y-%m-%d)
    timestamp=`date -d "${current_date}" +%s`
    #timestamp=1467388800
    inc_start_time=$((timestamp-86400))
    inc_end_time=$timestamp
    inc_month=$(date -d @$inc_start_time  "+%m" | sed s'/^0//')

    year=`date +%Y`
    total_month=12
    length=`expr $total_month / $save_time`
    counter=0
    begin=0
    while [ $counter -lt $length ]
    do
        if [ "$counter" = "0" ]; then
            begin=`expr $begin + 1`
        else
            begin=`expr $begin + $save_time`
        fi  
        end=`expr $begin + ${save_time} - 1`
        history_table_name="${dist_mysql_tables}_history_${year}_${begin}_${end}";
        if [ $inc_month -ge $begin ] && [ $inc_month -le $end ];then
            break
        fi
        counter=`expr $counter + 1`
    done
    condition="${cut_table_by_field} >= ${inc_start_time} AND ${cut_table_by_field} < ${inc_end_time}"
    #保存数据
    saveData "${history_table_name}" "${source_mysql_tables}" "${condition}"
    log "increament cut table data to $history_table_name success!!!"
}



#保存数据,无法拷备索引
function saveDataByCreate(){
    dist_table="$1"
    source_table="$2"
    condition="$3"
    where=''
    if [ -n "$condition" ]; then
        where="WHERE ${condition}"
    fi
    sql="CREATE TABLE ${dist_table} SELECT * FROM ${source_table} ${where}"
    querySql "$sql"
}


#保存数据
function saveData(){
    dist_table="$1"
    source_table="$2"
    condition="$3"
    #如果有where条件
    if [ -n "$condition" ]; then
        sql="INSERT INTO $dist_table SELECT * FROM $source_table WHERE $condition"
        querySql "$sql"
        #$mysqldump -h$source_mysql_host -u$source_mysql_user -p$source_mysql_pwd -P$source_mysql_port -c --no-create-info $source_mysql_db $source_table --where="$condition" | sed  "s/${source_table}/${dist_table}/g" | $mysql -h$dist_mysql_host -u$dist_mysql_user -p$dist_mysql_pwd -P$dist_mysql_port --force --no-beep -C $dist_mysql_db
    else
        sql="INSERT INTO $dist_table SELECT * FROM $source_table"
        querySql "$sql"
        #$mysqldump -h$source_mysql_host -u$source_mysql_user -p$source_mysql_pwd -P$source_mysql_port -c --no-create-info $source_mysql_db $source_table | sed  "s/${source_table}/${dist_table}/g" | $mysql -h$dist_mysql_host -u$dist_mysql_user -p$dist_mysql_pwd -P$dist_mysql_port --force --no-beep -C $dist_mysql_db
    fi
}

#日志记录
function log(){
    echo "-----------------$1-----------------";
    echo "=================`date "+%Y-%m-%d %H:%M:%S"`================" 
    echo -e "\n"
    echo "=================`date "+%Y-%m-%d %H:%M:%S"`================$1" >> ${logfile}
}


#执行SQL
function querySql(){
    sql=$1;
    $mysql -h$dist_mysql_host -u$dist_mysql_user -p$dist_mysql_pwd -P$dist_mysql_port --force --no-beep  -C $dist_mysql_db -e "$sql"
}

#清除主表90天之前的数据
function removeData(){
    current_date=$(date +%Y-%m-%d)
    timestamp=`date -d "${current_date}" +%s`
    #timestamp=1467388800
    remove_end_time=$((timestamp-(86400*90)))
    sql="DELETE FROM $source_mysql_tables WHERE $cut_table_by_field < $remove_end_time"
    querySql "$sql"
}

#主入口
function main() {
    if [ "$1" == "init" ];then
        initCutTable
    else
        incCutTable
        #removeData
    fi
}

main $*
