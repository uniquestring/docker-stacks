#!/bin/bash

LABEL_stack="mayan-edms"
LABEL_name="mysql"

# check for root
if [ "$EUID" -ne 0 ]; then
  echo -e "It's recommended to run this script as root."\
           "\nThe backup might be incomplete if you are missing reading permissions for some of the files!"
  read -p "Do you still want to continue ?[y/N]" -n 1 -r
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Backup cancelled!"
    exit 1
  fi
  echo
fi

echo "Starting backup ..."

# make sure exactly one mysql container is running
container=$(docker container ls --filter "label=stack=${LABEL_stack}" \
                    --filter "status=running" \
                    --filter "label=container=${LABEL_name}" \
                    --format '{{.ID}}')
if [[ $(echo ${container} | wc -w) -ne 1 ]]; then
  echo "ERROR: Expected exactly one mysql container! Detected: $(echo ${container} | wc -w)"
  exit 1
fi

# make DB backup
docker exec ${container} /bin/sh -c "/backup.sh" || exit 1

cd ..
cp ./stack_dms-mysql/.docker/mysql/import/backup.sql.gz ./stack_dms-mayanedms/
tar -czf ./backup/data/fullbackup-$(date +%Y-%m-%d-%H%M%S).tar.gz -C ./stack_dms-mayanedms/ backup.sql.gz data
rm -rf ./stack_dms-mayanedms/backup.sql.gz