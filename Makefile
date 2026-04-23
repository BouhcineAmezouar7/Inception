NAME = inception
COMPOSE_FILE = srcs/docker-compose.yml

# -f $(COMPOSE_FILE) : Specifies which compose file to use
COMPOSE = docker compose -p $(NAME) -f $(COMPOSE_FILE)

LOGIN = bamezoua

DATA_DIR = /home/$(LOGIN)/data

all: build

prepare-data:
	mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wp $(DATA_DIR)/redis

#   -d : Detached mode (runs in background)
#   --build : Rebuilds images even if they already exist
build: prepare-data
	$(COMPOSE) up -d --build

# Starts all services defined in docker-compose.yml
up: prepare-data
	$(COMPOSE) up -d

# Gracefully stops running containers and removes them
# Also removes Docker networks created by this project
down:
	$(COMPOSE) down

re: down build

# Completely removes containers, networks, AND volumes
clean:
	$(COMPOSE) down --volumes

# WARNING: ⚠️⚠️⚠️ This is irreversible - you lose everything!
fclean: clean
	docker system prune -fa      # Remove unused containers, images, networks, cache
	docker volume prune -f       # Remove unused volumes
	$(COMPOSE) down --rmi all    # Remove all project images
	sudo rm -rf $(DATA_DIR)      # Delete data directory from host machine

# Lists all containers currently running for this project
ps:
	$(COMPOSE) ps

# Display logs from all containers and follow new entries
#   -f : Follow mode (like 'tail -f') - shows logs as they happen
logs:
	$(COMPOSE) logs -f

# This tells Make these targets are commands, not files
.PHONY: all prepare-data build up down re clean fclean ps logs
