#!/bin/bash
set -e

# Logging for debugging purposes
echo "Starting WordPress setup..."

# Check connectivity to MariaDB
until mariadb-admin ping -h"mariadb" --silent; do
    echo "Waiting for MariaDB..."
    sleep 2
done

# Navigate to the correct directory
cd /var/www/wordpress

if [ ! -f "wp-config.php" ]; then
    echo "Downloading and configuring WordPress..."
    wp core download --allow-root
    
    # Use secrets for database password
    DB_PWD=$(cat /run/secrets/db_password)
    
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PWD" \
        --dbhost="mariadb:3306"

    echo "Running WordPress installation..."
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
fi

# Subject requirement: Ensure proper ownership
chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

echo "WordPress is ready. Starting PHP-FPM..."
# Use exec to ensure PHP-FPM is PID 1
exec php-fpm7.4 -F