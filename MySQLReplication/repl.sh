#!/bin/sh
BACKUP_BIN=/usr/bin/mysqlbinlog
LOCAL_BACKUP_DIR=/home/ubuntu/bbvs-binlog/
BACKUP_LOG=/home/ubuntu/backup.log

REMOTE_HOST=18.191.88.155
REMOTE_PORT=3306
REMOTE_USER=repl
REMOTE_PASS=123456
FIRST_BINLOG=mysql-bin.000019

#time to wait before reconnecting after failure
SLEEP_SECONDS=10

##create local_backup_dir if necessary
##mkdir -p ${LOCAL_BACKUP_DIR}
cd ${LOCAL_BACKUP_DIR}

while :
do
  if [ `ls -A "${LOCAL_BACKUP_DIR}" |wc -l` -eq 0 ];then
     LAST_FILE=${FIRST_BINLOG}
  else
     LAST_FILE=`ls -l ${LOCAL_BACKUP_DIR} | grep -v backuplog |tail -n 1 |awk '{print $9}'`
  fi
  ${BACKUP_BIN} --raw --read-from-remote-server --stop-never --host=${REMOTE_HOST} --port=${REMOTE_PORT} --user=${REMOTE_USER} --password=${REMOTE_PASS} ${LAST_FILE}

  echo "`date +"%Y/%m/%d %H:%M:%S"` mysqlbinlog stop, return code$?" | tee -a ${BACKUP_LOG}
  echo "${SLEEP_SECONDS} seconds after, repeat." | tee -a ${BACKUP_LOG}
  sleep ${SLEEP_SECONDS}
done
