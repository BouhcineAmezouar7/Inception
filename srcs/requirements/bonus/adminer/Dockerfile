# Adminer - Database management UI
# Base: Debian 12

FROM debian:12

# Install PHP and download Adminer
RUN apt update && \
    apt install -y php php-mysqli wget && \
    mkdir -p /var/www/html && \
    wget https://www.adminer.org/latest.php -O /var/www/html/index.php

WORKDIR /var/www/html
# Start PHP built-in server on port 8080
ENTRYPOINT ["php", "-S", "0.0.0.0:8080"]