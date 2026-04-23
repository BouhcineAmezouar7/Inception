# Developer Documentation (Inception)

This document explains how to set up, build, run, and maintain the project as a developer.

## 1) Prerequisites

### Required software

- **Docker Engine** (daemon running)
- **Docker Compose** CLI
  - This repository's `Makefile` uses the `docker-compose` command (Compose v1 style).
  - If your system only has `docker compose` (Compose v2 plugin), either install `docker-compose` or adapt the `Makefile`.
- **GNU Make**

### Required permissions / host requirements

- Ability to bind to ports **443**, **21**, and **21100–21110** on the host.
- Ability to create and write persistent directories under:
  - `/home/bamezoua/data/db`
  - `/home/bamezoua/data/wp`
  - `/home/bamezoua/data/redis`

## 2) Configuration and "secrets"

### Environment file

The project loads variables from:

- `srcs/.env`

It is used by multiple services via `env_file` in `srcs/docker-compose.yml`.

Variables include (non-exhaustive):

- MariaDB: `DB_NAME`, `DB_USER`, `DB_PASS`, `DB_HOST`
- WordPress: `DOMAIN_NAME`, `WP_ADMIN`, `WP_ADMIN_PASS`, `WP_ADMIN_EMAIL`, `WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASS`
- Redis: `REDIS_HOST`, `REDIS_PORT`
- FTP: `FTP_USER`, `FTP_PASS`

Security note: in a real project you typically do **not** commit secrets. For this educational project it may be acceptable, but treat `srcs/.env` as sensitive.

### Hostnames and TLS

NGINX is configured for the hostname `bamezoua.42.fr`:

- NGINX `server_name` is set in `srcs/requirements/nginx/conf/nginx.conf`.
- A self-signed certificate is generated inside the NGINX image with CN `bamezoua.42.fr` (see `srcs/requirements/nginx/tools/generate_cert.sh`).
- WordPress installs itself using `DOMAIN_NAME` from `srcs/.env`.

For local development, map the hostname(s) to `127.0.0.1`:

```bash
sudo sh -c 'printf "\n127.0.0.1 bamezoua.42.fr\n" >> /etc/hosts'
```

If you change hostnames, update both the NGINX config and `DOMAIN_NAME` in `.env`.

## 3) Build and launch (Makefile + Docker Compose)

### Makefile entry points

From repo root:

- Build images + start containers:

```bash
make
```

- Build only:

```bash
make build
```

- Stop containers:

```bash
make down
```

- Rebuild and restart:

```bash
make re
```

- View logs:

```bash
make logs
```

- Full cleanup:

```bash
make fclean
```

`make fclean` will:

- remove Docker images
- prune volumes
- run `docker-compose down -v`
- delete `/home/bamezoua/data`

### Direct Compose usage

All compose operations target `srcs/docker-compose.yml`:

```bash
docker-compose -f srcs/docker-compose.yml ps
```

Useful commands:

- Follow logs for one service:

```bash
docker-compose -f srcs/docker-compose.yml logs -f nginx
```

- Open a shell in a running container:

```bash
docker-compose -f srcs/docker-compose.yml exec wordpress sh
```

- Restart one service:

```bash
docker-compose -f srcs/docker-compose.yml restart nginx
```

## 4) Where data is stored (persistence)

This project persists data using **bind-mounted host directories** (declared as volumes in Compose).

### Persistent paths on the host

- MariaDB data directory:
  - Host: `/home/bamezoua/data/db`
  - Container: `/var/lib/mysql`

- WordPress files (site + uploads + generated config):
  - Host: `/home/bamezoua/data/wp`
  - Container: `/var/www/html`

- Redis cache data:
  - Host: `/home/bamezoua/data/redis`
  - Container: `/data`

These are defined in `srcs/docker-compose.yml` under `volumes:` using `driver_opts` with `type: none` and `o: bind`.

### What persists across restarts?

- Container restarts and `make down` do **not** remove the host directories.
- WordPress installation state (files and config) persists in `/home/bamezoua/data/wp`.
- MariaDB tables persist in `/home/bamezoua/data/db`.
- Redis data persists in `/home/bamezoua/data/redis`.

### How to reset to a clean state

To fully reset (delete database + WordPress files):

```bash
make fclean
make
```

Be careful: this deletes `/home/bamezoua/data`.

## 5) Service internals (where to look when debugging)

- WordPress bootstrap logic: `srcs/requirements/wordpress/tools/entrypoint.sh`
  - waits for DB, downloads WP, creates `wp-config.php`, installs WP, enables Redis cache.

- MariaDB initialization: `srcs/requirements/mariadb/tools/setup.sh`
  - initializes datadir on first run, creates the DB/user from `.env`.

- NGINX SSL certificate generation: `srcs/requirements/nginx/tools/generate_cert.sh`
  - generates self-signed certificate with CN from `DOMAIN_NAME`.

- Reverse proxy routes and configuration: `srcs/requirements/nginx/conf/nginx.conf`
  - HTTPS on port 443
  - reverse proxy to WordPress PHP-FPM on port 9000
  - request rewriting for WordPress routing

- FTP service setup: `srcs/requirements/bonus/ftp/tools/setup.sh`
  - creates FTP user and sets up chroot jail
  - configures passive mode port range

If WordPress keeps reinstalling or credentials don't match, check whether `/home/bamezoua/data/*` already contains old state.

## 6) Container structure

### Service dependency order

Docker Compose starts services in the order specified:

1. **MariaDB** - database initialization happens first
2. **Redis** - cache service
3. **WordPress** - waits for MariaDB and Redis, then initializes
4. **NGINX** - reverse proxy, waits for WordPress

Bonus services:

- **Adminer** - lightweight database UI on port 8080
- **FTP** - file transfer on port 21
- **Portainer** - Docker UI on port 9443
- **Website** - static website on port 1337

### Communication

- All containers communicate via the custom bridge network `inception_network`
- Service names (container names) are resolved via Docker DNS
- External traffic only enters through NGINX on port 443

## 7) Common development tasks

### Changing WordPress configuration

WordPress configuration is in `wp-config.php` (generated during init). To modify:

1. Edit via WordPress admin UI (preferred)
2. Or modify directly in `/home/bamezoua/data/wp/wp-config.php` and restart PHP-FPM:

```bash
docker-compose -f srcs/docker-compose.yml restart wordpress
```

### Database queries / inspection

Connect to MariaDB:

```bash
docker-compose -f srcs/docker-compose.yml exec mariadb mysql -u root -p
```

Then run SQL queries. Use the password from `DB_PASS` in `.env`.

### Checking Docker network

Inspect the `inception_network`:

```bash
docker network inspect inception_network
```

### Viewing file permissions issues

If a service fails due to permissions, check the host directories:

```bash
ls -la /home/bamezoua/data/
```

The containers run services as specific users (e.g., `www-data` for PHP). Ensure ownership is correct.

## 8) Dockerfile structure

Each service has a custom Dockerfile in `srcs/requirements/SERVICE/Dockerfile`:

- **NGINX**: installs openssl for certificate generation, nginx for serving
- **WordPress**: installs PHP-FPM, PHP extensions (mysql, redis), WordPress CLI
- **MariaDB**: installs mariadb-server, runs initialization script
- **Redis**: installs redis-server, runs with custom bind settings
- **FTP**: installs vsftpd, runs setup script for users
- **Adminer**: lightweight PHP image with single adminer.php file
- **Portainer**: downloads and runs Portainer binary
- **Website**: NGINX serving static HTML

All images are based on **Debian 12** for consistency and stability.
