# Portainer - Docker container management UI
# Base: Debian Bullseye

FROM debian:bullseye

# Download and install Portainer
RUN apt update && \
    apt install -y wget ca-certificates && \
    wget https://github.com/portainer/portainer/releases/download/2.20.3/portainer-2.20.3-linux-amd64.tar.gz && \
    tar -xzf portainer-2.20.3-linux-amd64.tar.gz -C /opt && \
    rm portainer-2.20.3-linux-amd64.tar.gz && \
    chmod +x /opt/portainer/portainer && \
    rm -rf /var/lib/apt/lists/*

# Expose port 9443 for secure access to Portainer UI
EXPOSE 9443

# /opt/portainer/portainer: Portainer executable
# --bind 0.0.0.0:9443: Bind to all interfaces at port 9443
# --data /data: Directory where Portainer stores data and configuration
ENTRYPOINT ["/opt/portainer/portainer", "--bind", "0.0.0.0:9443", "--data", "/data"]
