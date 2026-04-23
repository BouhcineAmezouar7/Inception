# FTP server (VSFTPD)
# Base: Debian 12

FROM debian:12

# Install VSFTPD
RUN apt update && apt install -y vsftpd && rm -rf /var/lib/apt/lists/*

# Copy configuration and setup script
COPY vsftpd.conf /etc/vsftpd.conf
COPY tools/setup.sh /setup.sh

# Make setup script executable
RUN chmod +x /setup.sh

# Expose FTP ports (control and passive data transfer)
EXPOSE 21 21100-21110

# Run setup script at startup
ENTRYPOINT ["/setup.sh"]
