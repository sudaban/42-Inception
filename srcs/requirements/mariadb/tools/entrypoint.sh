#!/bin/bash
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    until mysqladmin ping; do sleep 1; done

    # SQL commands
    # Passwords from secrets
    DB_PASS=$(cat /run/secrets/db_password)
    ROOT_PASS=$(cat /run/secrets/db_root_password)

    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';"
    mysql -u root -p"${ROOT_PASS}" -e "CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};"
    mysql -u root -p"${ROOT_PASS}" -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -p"${ROOT_PASS}" -e "GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"
    mysql -u root -p"${ROOT_PASS}" -e "FLUSH PRIVILEGES;"
    
    mysqladmin -u root -p"${ROOT_PASS}" shutdown
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql