#!/bin/bash
# wait until db ready
until mysqladmin -h mariadb -u ${MYSQL_USER} -p$(cat /run/secrets/db_password) ping; do
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    wp core download --allow-root
    wp config create --dbname=${MYSQL_DATABASE} --dbuser=${MYSQL_USER} \
        --dbpass=$(cat /run/secrets/db_password) --dbhost=mariadb --allow-root
    
    wp core install --url=${DOMAIN_NAME} --title="Inception" \
        --admin_user=${WP_ADMIN_USER} --admin_password=${WP_ADMIN_PASS} \
        --admin_email=${WP_ADMIN_EMAIL} --skip-email --allow-root
fi

# Run PHP-FPM in the foreground
exec php-fpm7.4 -F