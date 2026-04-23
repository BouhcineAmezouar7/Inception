# Start from official Debian 12 base image (lightweight foundation)
FROM debian:12

#   - mariadb-server: The database server (main process)
#   - mariadb-client: Client tools for connecting to and managing the database
RUN apt-get update && \
    apt-get install -y \
        mariadb-server \
        mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY tools/setup.sh /setup.sh

# Make the setup script executable (chmod +x adds execute permission)
RUN chmod +x /setup.sh

# Expose port 3306 (MariaDB default port)
EXPOSE 3306

# Run setup script when container starts
ENTRYPOINT ["/setup.sh"]
