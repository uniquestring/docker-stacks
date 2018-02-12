#!/bin/bash

OUTDIR="/docker-entrypoint-initdb.d"
err=false

echo "DB backup started ..."

# dump DB; replace old backup if dump was successful
mysqldump -u ${MYSQL_USER} --password=${MYSQL_PASSWORD} ${MYSQL_DATABASE} \
             > /tmp/dump.sql \
&& ( rm -rf /${OUTDIR}/* && \
     gzip -c /tmp/dump.sql > ${OUTDIR}/backup.sql.gz ) \
|| err=true

rm -rf /tmp/dump.sql

if [[ $err = true ]]; then
  echo "ERROR while dumping database!"
  exit 1
else
  echo "DB backup done!"
fi