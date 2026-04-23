*This project has been created as part of the 42 curriculum by bamezoua.*

# Inception 🐳

A complete Docker-based infrastructure project that demonstrates containerization, orchestration, and system administration concepts.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Environment Configuration](#environment-configuration)
- [Architecture](#architecture)
- [Available Services](#available-services)
- [Commands](#commands)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

---

## Overview

Inception is a system administration project based on **Docker and container orchestration**.

The goal is to design and deploy a small secure infrastructure composed of multiple services running in isolated containers. Each service runs independently while communicating with others through a dedicated Docker network.

### Key Features

✅ Multi-container architecture with Docker Compose  
✅ HTTPS/TLS encryption with NGINX reverse proxy  
✅ WordPress with MariaDB backend  
✅ Redis caching layer  
✅ FTP server for file management  
✅ Database management (Adminer)  
✅ Container orchestration (Portainer)  
✅ Static website hosting  
✅ Data persistence with Docker volumes  
✅ Secure internal networking  

### Main Design Choices

- **One service per container** - Single Responsibility Principle
- **Only NGINX exposes port 443 to the host** - Security through isolation
- **Internal communication through custom bridge network** - Service discovery via DNS
- **Data persistence using Docker volumes** - Data survives container restarts
- **Reverse proxy architecture** - Centralized traffic routing
- **Separation of concerns** - Configuration separated from runtime data

---

## Prerequisites

### System Requirements

- **Docker** (v20.10+)
- **Docker Compose** (v2.0+)
- **Make** (build tool)
- **Linux/macOS** (Windows requires WSL2)
- **Minimum 4GB RAM**
- **10GB free disk space**

### Installation

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose make
sudo usermod -aG docker $USER
```

**macOS (with Homebrew):**
```bash
brew install docker docker-compose
```

**Verify installation:**
```bash
docker --version
docker-compose --version
```

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/BouhcineAmezouar7/Inception_1337.git
cd Inception_1337
```

### 2. Configure Environment Variables

Create `srcs/.env` with your configuration:

```bash
cp srcs/.env.example srcs/.env
nano srcs/.env
```

### 3. Update Your Domain

Edit your `/etc/hosts` file to map your domain locally:

```bash
# Ubuntu/Linux
sudo nano /etc/hosts

# macOS
sudo nano /etc/hosts
```

Add the following line:
```
127.0.0.1    yourdomain.42.fr
```

### 4. Build and Start Services

```bash
make build    # Build all Docker images
make up       # Start all services
```

### 5. Access the Services

| Service | URL | Port |
|---------|-----|------|
| **WordPress** | https://yourdomain.42.fr | 443 |
| **Adminer** | http://localhost:8080 | 8080 |
| **Portainer** | https://localhost:9443 | 9443 |
| **Static Website** | http://localhost:1337 | 1337 |
| **FTP** | localhost | 21 |

---

## Environment Configuration

### Example `.env` File

Create `srcs/.env` with the following structure:

```dotenv
# Domain Configuration
DOMAIN_NAME=bamezoua.42.fr

# MariaDB Database Configuration
DB_HOST=mariadb
DB_NAME=wordpress
DB_USER=wp_user
DB_PASS=WordPressSecure456!

# WordPress Admin User
WP_ADMIN=bouhcine
WP_ADMIN_PASS=Bouhcine1337!
WP_ADMIN_EMAIL=bouhcine@student.42.fr

# WordPress Regular User
WP_USER=author_user
WP_USER_EMAIL=author@student.42.fr
WP_USER_PASS=AuthorSecure321!

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# FTP Server Configuration
FTP_USER=wpuser
FTP_PASS=WordPressSecure456!
```

### Environment Variables Explained

| Variable | Description | Example |
|----------|-------------|---------|
| `DOMAIN_NAME` | Your domain for NGINX and SSL | `yourdomain.42.fr` |
| `DB_HOST` | MariaDB container hostname | `mariadb` |
| `DB_NAME` | WordPress database name | `wordpress` |
| `DB_USER` | Database user (NOT root) | `wp_user` |
| `DB_PASS` | Database user password | Strong password |
| `WP_ADMIN` | WordPress admin username | `admin` |
| `WP_ADMIN_PASS` | WordPress admin password | Strong password |
| `WP_ADMIN_EMAIL` | WordPress admin email | `admin@example.com` |
| `REDIS_HOST` | Redis service hostname | `redis` |
| `REDIS_PORT` | Redis service port | `6379` |
| `FTP_USER` | FTP username | `ftpuser` |
| `FTP_PASS` | FTP password | Strong password |

### 🔐 Security Best Practices

- ✅ Use strong passwords (min 12 characters with mixed case, numbers, symbols)
- ✅ Never commit `.env` to git (already in `.gitignore`)
- ✅ Change default credentials before production deployment
- ✅ Use different passwords for each service
- ✅ Rotate credentials periodically

---

## Architecture

### Container Layout

```
┌─────────────────────────────────────────────┐
│       Docker Custom Bridge Network           │
│                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐ │
│  │  NGINX   │  │WordPress │  │ MariaDB  │ │
│  │  :443    │  │  :9000   │  │  :3306   │ │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘ │
│        │             │             │      │
│  ┌─────┴─────┐  ┌────┴──────┐  ┌──┴─────┐│
│  │  Redis    │  │ Adminer   │  │Portainer││
│  │  :6379    │  │  :8080    │  │ :9443   ││
│  └───────────┘  └───────────┘  └─────────┘│
│                                             │
│  ┌──────────┐  ┌──────────┐                │
│  │   FTP    │  │ Website  │                │
│  │  :21     │  │ :1337    │                │
│  └──────────┘  └──────────┘                │
└─────────────────────────────────────────────┘

External Access
       │
       ↓
   NGINX :443 (Only exposed port)
   ↓  ↓  ↓
  All internal services
```

### Service Communication

- **External Access**: Only NGINX port 443 is exposed
- **Internal DNS**: Services use container names for communication
- **Volumes**: Data persists in Docker-managed volumes
- **Network Isolation**: Custom bridge network isolates containers

---

## Available Services

### 🌐 NGINX (Reverse Proxy)
- Handles HTTPS/TLS termination
- Routes traffic to WordPress
- Generates self-signed SSL certificates
- **Port**: 443 (external)

### 📝 WordPress (PHP-FPM)
- Content management system
- Communicates with MariaDB for data
- Uses Redis for object caching
- **Port**: 9000 (internal)

### 🗄️ MariaDB (Database)
- Relational database for WordPress
- Persistent volume storage
- User and password authentication
- **Port**: 3306 (internal)

### ⚡ Redis (Cache Layer)
- In-memory data store
- Improves WordPress performance
- Session caching
- **Port**: 6379 (internal)

### 📊 Adminer (Database UI)
- Web-based database management
- Create, read, update, delete records
- View database structure
- **Port**: 8080 (external)

### 🐳 Portainer (Container Management)
- Docker container GUI
- Manage containers, images, volumes
- Monitor resource usage
- **Port**: 9443 (external)

### 📤 FTP Server (VSFTPD)
- File transfer protocol
- Upload/download files to WordPress
- User authentication
- **Port**: 21 (external)

### 🌍 Static Website
- Simple static HTML website
- Nginx-based hosting
- Demo/landing page
- **Port**: 1337 (external)

---

## Commands

### Build and Start

```bash
# Build all images and start containers
make build

# Start existing containers
make up

# Rebuild (clean + build)
make re
```

### Monitor and Debug

```bash
# View all running containers
make ps

# Follow live logs from all services
make logs

# View logs from specific container
docker compose -f srcs/docker-compose.yml logs -f wordpress

# Inspect a container
docker inspect inception-nginx-1
```

### Stop and Clean

```bash
# Stop all containers (preserves volumes)
make down

# Remove containers and volumes
make clean

# Full clean: remove everything (DESTRUCTIVE!)
make fclean
```

### Useful Docker Commands

```bash
# Enter a running container
docker exec -it inception-wordpress-1 bash

# View container processes
docker top inception-mariadb-1

# Check network configuration
docker network inspect inception

# View volume information
docker volume ls
docker volume inspect inception_wp_data
```

---

## Troubleshooting

### Common Issues

**1. Port Already in Use**
```bash
# Find process using port 443
sudo lsof -i :443

# Kill the process
sudo kill -9 <PID>
```

**2. Domain Not Resolving**
```bash
# Check hosts file
cat /etc/hosts

# Flush DNS cache
sudo systemd-resolve --flush-caches

# Verify DNS resolution
nslookup yourdomain.42.fr
```

**3. SSL Certificate Issues**
```bash
# Regenerate certificates
rm -rf srcs/requirements/nginx/conf/ssl/
make re
```

**4. Database Connection Failed**
```bash
# Check database container logs
docker compose -f srcs/docker-compose.yml logs mariadb

# Verify DB credentials in .env
cat srcs/.env
```

**5. WordPress Shows Database Error**
```bash
# Check WordPress logs
docker exec inception-wordpress-1 tail -f /var/log/php-fpm.log

# Verify network connectivity
docker exec inception-wordpress-1 ping mariadb
```

**6. Permission Denied on Data Directory**
```bash
# Fix directory ownership
sudo chown -R $USER:$USER /home/$(whoami)/data
sudo chmod -R 755 /home/$(whoami)/data
```

---

## Technical Deep Dive

### Docker Concepts Used

**Namespaces**: Isolate processes
- PID namespace: Process isolation
- Network namespace: Network stack isolation
- Mount namespace: Filesystem isolation

**Cgroups**: Resource management
- Memory limits
- CPU allocation
- I/O restrictions

**Union FileSystem**: Layer images
- Base images as read-only layers
- Changes in writable layer
- Efficient storage

### Network Design

```
Bridge Network: inception
├── NGINX: 172.20.0.2
├── WordPress: 172.20.0.3
├── MariaDB: 172.20.0.4
├── Redis: 172.20.0.5
├── Adminer: 172.20.0.6
└── FTP: 172.20.0.7
```

### Data Persistence

| Service | Volume | Mount Point |
|---------|--------|------------|
| MariaDB | `inception_db_data` | `/var/lib/mysql` |
| WordPress | `inception_wp_data` | `/var/www/wordpress` |
| Redis | `inception_redis_data` | `/data` |

---

## Resources

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [WordPress Codex](https://developer.wordpress.org/)

### Learning Materials
- [Docker Internals](https://docs.docker.com/engine/)
- [Linux Namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Linux Cgroups](https://man7.org/linux/man-pages/man7/cgroups.7.html)
- [Container Security](https://docs.docker.com/engine/security/)

---

## Use of AI

AI tools were used to:

- Clarify Docker internal concepts
- Debug networking and volume configuration issues
- Improve documentation clarity and structure
- Generate code comments and explanations
- Optimize configuration files

All implementation and configuration decisions were manually designed and understood.

---

## Author

**Bouhcine Amezouar**  
42 Cursus - bamezoua  
[GitHub](https://github.com/BouhcineAmezouar7)

---

## License

This project is part of the 42 curriculum and is provided as-is for educational purposes.
