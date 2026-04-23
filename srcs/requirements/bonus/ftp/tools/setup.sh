#!/bin/bash

# Initialize FTP server with user and permissions

set -e  # Exit on error

# Create chroot directory for VSFTPD
mkdir -p /var/run/vsftpd/empty
chmod 755 /var/run/vsftpd/empty


# Create FTP user if it doesn't exist
FTP_USERNAME="${FTP_USER:-wpuser}"
if ! id "$FTP_USERNAME" &>/dev/null; then
    useradd -m "$FTP_USERNAME"
fi

# Set FTP password
echo "${FTP_USERNAME}:${FTP_PASS:-ftp_pass}" | chpasswd
# Add FTP user to www-data group (for WordPress file access)
usermod -aG www-data "$FTP_USERNAME"


# Set WordPress directory ownership and permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Start FTP server in foreground
exec vsftpd /etc/vsftpd.conf