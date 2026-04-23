# USER Documentation (Inception)

This project runs a small web infrastructure using Docker Compose.

## 1) What services are provided?

Your stack provides these containers:

- **NGINX (TLS reverse proxy)**: entrypoint for the platform on port **443**.
- **WordPress (PHP-FPM)**: the main website/CMS.
- **MariaDB**: database used by WordPress.
- **Redis**: object cache used by WordPress (via the `redis-cache` plugin).
- **FTP (vsftpd)**: optional file access to the WordPress files.
- **Adminer**: lightweight database administration web UI.
- **Portainer**: web UI to manage Docker containers.
- **Static website**: small bonus website served by its own NGINX.

## 2) First-time hostname setup (important)

This project is configured for the hostname **`bamezoua.42.fr`** (see TLS certificate CN and NGINX `server_name`). To access it locally, add it to your hosts file:

```bash
sudo sh -c 'printf "\n127.0.0.1 bamezoua.42.fr\n" >> /etc/hosts'
```

If you change the hostname, you must update it in:

- `srcs/.env` (`DOMAIN_NAME=...`)
- `srcs/requirements/nginx/conf/nginx.conf` (`server_name ...`)

## 3) Start and stop the project

From the repository root:

- Start (build + run):

```bash
make
```

- Stop:

```bash
make down
```

- Rebuild and restart:

```bash
make re
```

- Remove everything (containers/images/volumes + persistent data directory):

```bash
make fclean
```

Note: `make` creates persistent directories under `/home/bamezoua/data/`.

## 4) Access the website and admin panels

### Main website (WordPress)

- Website: `https://bamezoua.42.fr/`
- WordPress admin panel: `https://bamezoua.42.fr/wp-admin/`

Because TLS uses a self-signed certificate, your browser will show a warning. Proceed/accept it.

### Adminer (database UI)

You can access Adminer in two ways:

- Behind the reverse proxy: `https://bamezoua.42.fr/adminer/`
- Directly via port mapping: `http://localhost:8080/`

Connection info for Adminer:

- **System**: MySQL / MariaDB
- **Server**: `mariadb`
- **Username**: value of `DB_USER` in `srcs/.env`
- **Password**: value of `DB_PASS` in `srcs/.env`
- **Database**: value of `DB_NAME` in `srcs/.env`

### Portainer (container management UI)

- Behind the reverse proxy: `https://bamezoua.42.fr/portainer/`
- Directly via port mapping: `https://localhost:9443/`

First visit: Portainer will ask you to create an admin user/password.

### Static website

- Behind the reverse proxy: `https://bamezoua.42.fr/static-website/`
- Directly via port mapping: `http://localhost:1337/`

### FTP access (optional)

FTP is exposed on:

- Control port: **21**
- Passive ports: **21100–21110**

Use any FTP client and connect to `localhost` (or your host IP) with the credentials in `srcs/.env`:

- `FTP_USER`
- `FTP_PASS`

Uploaded/edited files are inside the WordPress shared volume (same files served by NGINX/WordPress).

## 5) Locate and manage credentials

All initial credentials are stored in:

- `srcs/.env`

This file includes:

- MariaDB database name/user/password (`DB_NAME`, `DB_USER`, `DB_PASS`)
- WordPress site URL and admin account (`DOMAIN_NAME`, `WP_ADMIN`, `WP_ADMIN_PASS`, `WP_ADMIN_EMAIL`)
- Additional WordPress user (`WP_USER`, `WP_USER_EMAIL`, `WP_USER_PASS`)
- FTP user/password (`FTP_USER`, `FTP_PASS`)
- Redis configuration (`REDIS_HOST`, `REDIS_PORT`)

### Changing credentials safely

- **WordPress admin password**: can be changed from the WordPress admin UI.
- **Database / FTP credentials**: changing values in `srcs/.env` may require a full reset to re-initialize services using the new credentials.

Typical approaches:

- Restart containers after changing `.env`:

```bash
make re
```

- If you changed DB initialization credentials and want a clean re-init:

```bash
make fclean
make
```

Warning: `make fclean` deletes `/home/bamezoua/data/` (your persisted database and WordPress files).

## 6) Check that services are running correctly

### Quick checks

- Container status:

```bash
docker ps
```

- Compose status:

```bash
docker-compose -f srcs/docker-compose.yml ps
```

- Logs:

```bash
make logs
```

### Endpoint checks

- NGINX/WordPress (ignore TLS warning with `-k`):

```bash
curl -kI https://bamezoua.42.fr/
```

- Adminer:

```bash
curl -I http://localhost:8080/
```

- Portainer:

```bash
curl -kI https://localhost:9443/
```

If something fails, start with `make logs` and then focus on the failing service logs.
