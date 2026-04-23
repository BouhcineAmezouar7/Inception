#!/bin/bash

set -e

echo "Waiting for MariaDB..."

# Wait for MariaDB database to be ready and accepting connections
# mysql: MySQL client command
# >/dev/null 2>&1: Discard all output (stdout and stderr)
until mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -e "SELECT 1" >/dev/null 2>&1; do
    sleep 2
done

echo "MariaDB is up!"

# Check if WordPress core is already installed
if [ ! -f wp-load.php ]; then
    # Download WordPress core files
    wp core download --allow-root
    
    # Create WordPress configuration file (wp-config.php)
    wp config create \
        --dbname="$DB_NAME" \
        --dbuser="$DB_USER" \
        --dbpass="$DB_PASS" \
        --dbhost="$DB_HOST" \
        --allow-root
fi

# Check if WordPress is NOT already installed in the database
if ! wp core is-installed --allow-root; then
    # initialize WordPress in the database
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="inception" \
        --admin_user="$WP_ADMIN" \
        --admin_password="$WP_ADMIN_PASS" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
    
    # Create additional WordPress user (author role)
    wp user create \
        $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASS \
        --role=author \
        --allow-root

    # add Redis caching configuration to wp-config.php
    wp config set WP_REDIS_HOST $REDIS_HOST --allow-root
    wp config set WP_REDIS_PORT $REDIS_PORT --allow-root
    
    # Install Redis cache plugin
    # --activate: Automatically activate plugin after install
    wp plugin install redis-cache --activate --allow-root
    
    # Enable Redis caching in WordPress
    wp redis enable --allow-root
fi

# used by PHP-FPM to serve files with www-data user permissions
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# Start PHP-FPM service
# exec: Replace current shell with PHP-FPM process (recommended for containers)
# -F: Run in foreground mode (don't fork to background)
exec php-fpm8.2 -F
