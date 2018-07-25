#!/bin/bash
###############Basic parameters##########################
DAY=`date +%Y%m%d`
Environment=$(/sbin/ifconfig | grep "inet addr" | head -1 |grep -v "127.0.0.1" | awk '{print $2;}' | awk -F':' '{print $2;}')
USER="backup"
PASSWD="bbvsbackup!@#"
HostPort="3306"
DATADIR="/var/www/jacky_bbv/backup/"
MYSQL=`/usr/bin/which mysql`
MYSQLDUMP=`/usr/bin/which mysqldump`
Dump(){
 ${MYSQLDUMP} --master-data=2 --single-transaction --routines --triggers --events -u${USER} -p${PASSWD} -P${HostPort} ${database}  > ${DATADIR}/${DAY}-${database}.sql
 gzip ${DATADIR}/${DAY}-${database}.sql
 # chmod 755 ${DATADIR}/${DAY}-${database}.sql.gz
}

for db in `echo "SELECT schema_name FROM information_schema.schemata where schema_name in ('bbvs')" | ${MYSQL} -u${USER} -p${PASSWD} --skip-column-names`
do
   database=${db}
   Dump
done
