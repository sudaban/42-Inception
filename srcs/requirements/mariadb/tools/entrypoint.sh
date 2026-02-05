#!/bin/bash
set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    
    until mysqladmin ping >/dev/null 2>&1; do
        echo "Waiting for MariaDB..."
        sleep 1
    done

    ROOT_PWD=$(cat /run/secrets/db_root_password)
    USER_PWD=$(cat /run/secrets/db_password)

    mysql -u root <<EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PWD';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$USER_PWD';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
EOF

    mysqladmin -u root -p"$ROOT_PWD" shutdown
fi

exec mysqld --user=mysql --datadir=/var/lib/mysql