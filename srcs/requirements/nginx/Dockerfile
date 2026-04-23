# NGINX web server with TLS support
# Base: Debian 12

FROM debian:12

# Install OpenSSL and NGINX
RUN apt-get update && \
    apt-get install -y openssl nginx && \
    rm -rf /var/lib/apt/lists/*

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Copy configuration files
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/generate_cert.sh /generate_cert.sh

# Make certificate generation script executable
RUN chmod +x /generate_cert.sh

# Expose HTTPS port
EXPOSE 443

# Generate certificates and start NGINX
ENTRYPOINT ["/generate_cert.sh"]