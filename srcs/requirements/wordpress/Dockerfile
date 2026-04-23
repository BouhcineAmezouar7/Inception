FROM debian:12

#   - php8.2-cli: PHP command-line interface (for running PHP scripts directly)
#   - php8.2-fpm: PHP FastCGI Process Manager (allows NGINX to execute PHP)
#   - php8.2-mysql: MySQL/MariaDB extension (enables PHP to query databases)
#   - php8.2-redis: Redis extension (enables PHP to use Redis caching)
#   - mariadb-client: MySQL client tools (for database connections and operations)
#   - curl: Command-line HTTP client (for downloading files from web)
RUN apt-get update && \
    apt-get install -y \
        php8.2-cli \
        php8.2-fpm \
        php8.2-mysql \
        php8.2-redis \
        mariadb-client \
        curl && \
    rm -rf /var/lib/apt/lists/*

# Download and install WordPress CLI (wp-cli) - command-line tool for WordPress management
# curl -O: Download file from URL to current directory with original name
# mv: Move/rename the file to /usr/local/bin/wp (standard location for executables)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Create the WordPress application directory
RUN mkdir -p /var/www/html

# Configure PHP-FPM to listen on port 9000 (where NGINX will connect)
# 's|listen = .*|listen = 9000|': Replace any "listen" setting with "listen = 9000"
RUN sed -i 's|listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Copy the entrypoint script from build context to container
COPY tools/entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# When container runs, this is the default directory
WORKDIR /var/www/html

# Expose port 9000 (FastCGI port where NGINX will connect)
EXPOSE 9000

# Set entrypoint script that runs when container starts
ENTRYPOINT ["/entrypoint.sh"]
