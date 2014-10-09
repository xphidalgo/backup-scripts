#!/bin/bash
# delete log files older than 30 days
#  0    0    *  *   *     find /var/www/webapp -type f -name '*.log' -mtime +30 -delete

# directorio donde se almacenara este backup
backup_dir=/var/backups/backupfolder/
backup_dir=$backup_dir$(date +'%Y-%m-%d')

# si ya existe el directorio volver a crearlo
if [ -d "$backup_dir" ]; then
        rm -rf "$backup_dir"
fi

# crear directorio y cambiar a el
mkdir -p "$backup_dir"
cd "$backup_dir"

USER="mysql_backup_user"
PASSWORD="mysql_backup_user_password"
MYSQL_TEMP_DIR="temp_mysql"
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"

mkdir "$MYSQL_TEMP_DIR"

# get a list of databases
databases=`$MYSQL -h 10.60.83.13 --user=$USER --password=$PASSWORD \
 -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`

# dump each database in turn
for db in $databases; do
    if [ $db == "mysql" ] || [ $db == "performance_schema" ] || [ $db == "information_schema" ]; then
        continue
    fi
    $MYSQLDUMP --force --opt -h 10.60.83.13 --user=$USER --password=$PASSWORD \
    --databases $db > "$backup_dir/$MYSQL_TEMP_DIR/$db.bak"
done

#comprimir la carpeta de las bbdd
zip -rq databases "$MYSQL_TEMP_DIR"
rm -rf "$MYSQL_TEMP_DIR"
#repositorios
#zip -rq repositories /home/git/repositories
#webs
zip -rq webs /var/www

find /var/backups/* -type d -mtime +7 -print0 | xargs -0 rm -rf