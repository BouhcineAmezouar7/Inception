# Redis - In-memory cache server
# Base: Debian 12

FROM debian:12

# Install Redis
RUN apt update && apt install -y redis-server && rm -rf /var/lib/apt/lists/*

# Expose Redis port
EXPOSE 6379

# Start Redis with network binding and protected mode disabled
ENTRYPOINT ["redis-server", "--bind", "0.0.0.0", "--protected-mode", "no"]
