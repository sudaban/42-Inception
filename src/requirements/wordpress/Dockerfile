FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php7.4-fpm php7.4-mysql curl mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# WP-CLI setup
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/

RUN mkdir -p /run/php && chmod +x /usr/local/bin/setup.sh

WORKDIR /var/www/wordpress
ENTRYPOINT ["setup.sh"]