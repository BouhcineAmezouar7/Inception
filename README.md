*This project has been created as part of the 42 curriculum by bamezoua.*

# Inception






\


## Description

Inception is a system administration and containerization project developed as part of the **1337 Coding School — 42 Network** curriculum.

The objective is to design, configure, and deploy a secure multi-service infrastructure using Docker and Docker Compose.

Each service runs inside an isolated container, built from a custom Dockerfile and connected through a dedicated Docker network. Persistent data is managed through Docker volumes.

The project provides practical experience with containerization, service orchestration, reverse proxies, networking, TLS encryption, database administration, caching, and infrastructure management.

## Infrastructure

### Mandatory Services

| Service   | Responsibility                                 |
| --------- | ---------------------------------------------- |
| NGINX     | HTTPS entry point and reverse proxy            |
| WordPress | Content management system running with PHP-FPM |
| MariaDB   | Relational database and persistent storage     |

### Bonus Services

| Service        | Responsibility                     |
| -------------- | ---------------------------------- |
| Redis          | WordPress object caching           |
| FTP            | Remote file access                 |
| Adminer        | Web-based database administration  |
| Portainer      | Docker container management        |
| Static Website | Lightweight static web application |

## Architecture

The core infrastructure is organized around NGINX, WordPress, and MariaDB, with Redis providing object caching.

```text
                 Client / Browser
                         │
                    HTTPS :443
                         │
                  ┌──────▼──────┐
                  │    NGINX    │
                  └──────┬──────┘
                         │ FastCGI
                  ┌──────▼──────┐
                  │  WordPress  │
                  │   PHP-FPM   │
                  └───┬─────┬───┘
                      │     │
             ┌────────▼─┐ ┌─▼────────┐
             │ MariaDB  │ │  Redis   │
             └────┬─────┘ └──────────┘
                  │
             Database Volume

        Dedicated Docker Bridge Network
```

The bonus services extend the infrastructure with database administration, container management, file access, and static content hosting.

## Use of Docker

Docker is used to isolate and manage each service independently instead of installing all services directly on the host operating system.

Docker relies on several Linux technologies:

- **Namespaces:** Isolate processes, networking, mounts, and other system resources.
- **Cgroups:** Manage and limit CPU, memory, and other resource usage.
- **Layered Images:** Provide reusable filesystem layers for efficient image building.
- **Docker Networks:** Enable communication between isolated containers.
- **Docker Volumes:** Preserve application data independently of container lifecycles.

Docker Compose defines, configures, and orchestrates the complete multi-container infrastructure.

## Design Choices

- One primary service per container.
- Custom Dockerfiles for individual services.
- HTTPS communication through NGINX on port 443.
- Dedicated bridge network for internal communication.
- Additional published ports for bonus services when required.
- Persistent storage for WordPress, MariaDB, and Redis.
- Separation of configuration, credentials, and application data.
- Service discovery through Docker's internal DNS.
- Independent container lifecycles.

## Technical Comparisons

### Virtual Machines vs Docker

| Virtual Machines                      | Docker Containers                      |
| ------------------------------------- | -------------------------------------- |
| Run a complete guest operating system | Share the host operating system kernel |
| Hardware-level virtualization         | Operating-system-level isolation       |
| Higher resource consumption           | Lower resource consumption             |
| Generally slower startup              | Generally faster startup               |
| Stronger isolation boundary           | Lightweight process isolation          |

Docker is particularly useful for deploying independent services without requiring a complete operating system for each instance.

### Secrets vs Environment Variables

| Environment Variables                       | Docker Secrets                                       |
| ------------------------------------------- | ---------------------------------------------------- |
| Easy to configure                           | Designed for sensitive information                   |
| Accessible through the process environment  | Typically provided through mounted files             |
| May be exposed through container inspection | Reduce direct exposure through environment variables |
| Suitable for general configuration          | Better suited for passwords and credentials          |

Secrets should not be committed to version control or embedded in Docker images.

In standalone Docker Compose, the security of secrets also depends on how their source files are stored and protected.

### Docker Network vs Host Network

| Bridge Network                               | Host Network                         |
| -------------------------------------------- | ------------------------------------ |
| Provides network isolation                   | Shares the host networking stack     |
| Supports internal service discovery          | Uses host networking directly        |
| Containers communicate through service names | Reduced network isolation            |
| Supports selective port publishing           | Services bind directly to host ports |

This project uses a dedicated bridge network to isolate services and manage internal communication.

### Docker Volumes vs Bind Mounts

| Docker Volumes                               | Bind Mounts                              |
| -------------------------------------------- | ---------------------------------------- |
| Managed through Docker                       | Map specific host filesystem paths       |
| Independent of container lifecycles          | Directly accessible from the host        |
| Suitable for persistent application data     | Useful for configuration and development |
| Storage managed through volume configuration | Depend on the host directory structure   |

The project uses persistent storage to preserve database records, WordPress files, and Redis data across container restarts and recreation.

## Getting Started

### Requirements

- Linux environment or Linux virtual machine
- Docker Engine
- Docker Compose
- GNU Make
- OpenSSL

Verify the installation:

```bash
docker --version
docker compose version
make --version
```

### Clone the Repository

```bash
git clone <repository_url>
cd inception
```

### Environment Configuration

Create and configure the environment file:

```bash
touch srcs/.env
```

Configure the variables required by the Docker Compose file and service initialization scripts.

Sensitive credentials and secret files should remain outside version control.

### Persistent Storage

Create the required data directories:

```bash
mkdir -p /home/bamezoua/data/{db,wp,redis}
```

These directories provide persistent storage for the corresponding services.

### Domain Configuration

Add the following entry to your local `/etc/hosts` file when running the infrastructure locally:

```text
127.0.0.1 bamezoua.42.fr
```

When running inside a remote virtual machine, replace `127.0.0.1` with the virtual machine's IP address.

### Build and Start

Build the Docker images:

```bash
make build
```

Start the infrastructure:

```bash
make up
```

Check running containers:

```bash
docker ps
```

View service logs:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

## Service Access

Once the infrastructure is running, services can be accessed through their configured addresses.

| Service        | Address                                          |
| -------------- | ------------------------------------------------ |
| WordPress      | [https://bamezoua.42.fr](https://bamezoua.42.fr) |
| Adminer        | [http://localhost:8080](http://localhost:8080)   |
| Portainer      | [https://localhost:9443](https://localhost:9443) |
| FTP            | localhost:21                                     |
| Static Website | [http://localhost:1337](http://localhost:1337)   |

Bonus service addresses depend on the port mappings defined in Docker Compose.

The browser may display a security warning when using a self-signed TLS certificate.

## Makefile Commands

| Command       | Description                           |
| ------------- | ------------------------------------- |
| `make build`  | Build Docker images                   |
| `make up`     | Start all configured services         |
| `make down`   | Stop and remove containers            |
| `make re`     | Rebuild the infrastructure            |
| `make fclean` | Perform a full infrastructure cleanup |

**Warning:** Before running `make fclean`, verify its cleanup rules. Removing volumes or host data directories may permanently delete persistent application data.

## Docker Management

Useful commands for inspecting and debugging the infrastructure:

```bash
# List running containers
docker ps

# List all containers
docker ps -a

# List Docker images
docker images

# List networks
docker network ls

# List volumes
docker volume ls

# Inspect a container
docker inspect <container_name>

# View container logs
docker logs <container_name>

# Access a running container
docker exec -it <container_name> sh

# Display container resource usage
docker stats
```

## Security

The infrastructure follows several security-oriented principles:

- TLS encryption for the main website.
- Isolation between services using Docker containers.
- Internal communication through a dedicated network.
- Selective publishing of container ports.
- Sensitive credentials kept outside Docker images and version control.
- Persistent data separated from application containers.
- Independent service configuration.

This infrastructure is designed for educational purposes and local deployment. Additional hardening is required before exposing administrative services to the public internet.

## Technical Concepts

Throughout this project, I explored:

- Linux system administration
- Containerization and process isolation
- Docker image construction
- Multi-container orchestration
- Linux namespaces and cgroups
- Docker networking and internal DNS
- Persistent storage and volume management
- Reverse proxy architecture
- TLS certificates and HTTPS
- PHP-FPM and FastCGI communication
- Database administration
- Redis object caching
- Infrastructure security
- Shell scripting and build automation

## Resources

The following resources were consulted during development:

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Networking](https://docs.docker.com/engine/network/)
- [Docker Volumes](https://docs.docker.com/engine/storage/volumes/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/docs/)
- [WordPress Developer Resources](https://developer.wordpress.org/)
- [Redis Documentation](https://redis.io/docs/)
- [Linux Namespaces](https://man7.org/linux/man-pages/man7/namespaces.7.html)
- [Linux Cgroups](https://man7.org/linux/man-pages/man7/cgroups.7.html)

## Use of AI

AI tools were used as a supplementary learning resource to deepen my understanding of Docker, Linux system administration, container networking, and service configuration. They also assisted with troubleshooting technical issues and improving project documentation.

All implementation and configuration decisions were manually reviewed and understood.

## Author

**Bouhcine Amezouar — bamezoua**

Software Engineering Student at 1337 & Full-Stack Developer

[GitHub](https://github.com/BouhcineAmezouar7) · [Portfolio](https://bouhcineamezouar.tech)

---

Developed as part of the **1337 Coding School — 42 Network** curriculum.
