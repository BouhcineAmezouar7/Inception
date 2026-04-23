# Static website server
# Base: Debian 12

FROM debian:12

# Install NGINX
RUN apt update && apt install -y nginx && rm -rf /var/lib/apt/lists/*

# Copy website configuration and content
COPY conf/default.conf /etc/nginx/sites-available/default
COPY tools/index.html /var/www/html/index.html

# Expose HTTP port
EXPOSE 80

# Start NGINX in foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
