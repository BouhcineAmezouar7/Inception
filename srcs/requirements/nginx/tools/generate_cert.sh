#!/bin/bash

# Generate self-signed SSL certificate and start NGINX

set -e  # Exit on error

# Certificate paths
CERT_DIR="/etc/nginx/ssl"
CERT_FILE="$CERT_DIR/nginx.crt"
KEY_FILE="$CERT_DIR/nginx.key"

# Domain from environment or default
DOMAIN="${DOMAIN_NAME:-bamezoua.42.fr}"

# Generate certificate if missing
if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
    echo "Generating SSL certificate for $DOMAIN..."
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout "$KEY_FILE" \
        -out "$CERT_FILE" \
        -subj "/C=MA/ST=casa-settat/L=Casablanca/O=1337/CN=$DOMAIN"
fi

echo "WordPress ready. Starting NGINX..."
exec nginx -g "daemon off;"
