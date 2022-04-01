#!/usr/bin/env bash
set -euo pipefail

send_files_to_remote_servers () {
    if [ "$verify" = true ] ; then
        echo "Exporting files with verification"
        /usr/bin/nice -n 10 /usr/bin/duply b2 backup_verify_purge --force
    else
        echo "Exporting files without verification"
        /usr/bin/duply b2 backup
        /usr/bin/duply b2 purge --force
    fi
}
echo "Running docker backup"

verify='false'
while getopts ':v' flag; do
  case "${flag}" in
    v) verify=true ;;
    *) echo `date`: "Unexpected option ${flag}" >&2; exit 1; ;;
  esac
done


echo "Dumping database"

MYSQL_PWD=$MYSQL_PWD mysqldump -u $MYSQL_USERNAME -h $MYSQL_HOST \
  --all-databases --add-drop-database --routines -E --triggers --single-transaction --column-statistics=0 | gzip > /data/db.sql.gz

send_files_to_remote_servers

echo "Backup completed"
