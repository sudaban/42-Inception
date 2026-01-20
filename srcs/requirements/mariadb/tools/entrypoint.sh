#!/bin/bash
set -e

# Check if the database is already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB temporarily to configure users
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    pid="$!"

    # Wait for the server to be ready
    until mysqladmin ping >/dev/null 2>&1; do
        echo "Waiting for MariaDB to start..."
        sleep 1
    done

    # Read secrets
    ROOT_PWD=$(cat /run/secrets/db_root_password)
    USER_PWD=$(cat /run/secrets/db_password)

    # Secure the installation and create users
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$ROOT_PWD';"
    mysql -u root -p"$ROOT_PWD" -e "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;"
    mysql -u root -p"$ROOT_PWD" -e "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$USER_PWD';"
    mysql -u root -p"$ROOT_PWD" -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';"
    mysql -u root -p"$ROOT_PWD" -e "FLUSH PRIVILEGES;"

    # Shutdown temporary instance
    mysqladmin -u root -p"$ROOT_PWD" shutdown
    echo "MariaDB initialization complete."
fi

# Execute MariaDB as PID 1
echo "Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql