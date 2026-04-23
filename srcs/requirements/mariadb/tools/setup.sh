#!/bin/sh

# Initialize MariaDB database with user and permissions

set -e  # Exit on error

# Create runtime directory
# for MariaDB to store its socket and PID files
# help to connect mariadb client to server using socket file
mkdir -p /run/mysqld

# Set ownership to mysql user
chown -R mysql:mysql /run/mysqld

# Initialize database if not already done
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Start temporary MariaDB instance for initialization
mysqld --skip-networking --user=mysql &

# Wait for MariaDB to be ready
until mysqladmin ping --silent; do
    sleep 1
done

# Create database, user, and grant privileges
mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

# Stop temporary instance
mysqladmin -u root shutdown

# Start MariaDB in foreground (main container process)
exec mysqld --bind-address=0.0.0.0 --user=mysql