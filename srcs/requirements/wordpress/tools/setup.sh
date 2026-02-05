#!/bin/bash
sleep 10

cd /var/www/wordpress

if [ ! -f "wp-config.php" ]; then

    wp core download --allow-root || true
    
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$(cat /run/secrets/db_password)" \
        --dbhost="mariadb:3306" --force

    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" \
        --title="Inception" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email

    wp user create "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$(cat /run/secrets/db_password)" \
        --role=author --allow-root
fi

echo "WordPress setup finished. Starting PHP-FPM..."
exec php-fpm7.4 -F