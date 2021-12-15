# Include environment variables from .env
include .env

RAILS_CMD=bin/rails
RAKE_CMD=bin/rake

# Colors
GREEN=\033[0;32m
RED=\033[0;31m
NC=\033[0m # No Color

# Gem railroady
diagram:
	$(RAKE_CMD) diagram:all;

# Database
db-create:
	$(RAILS_CMD) db:drop;			# Drop DB
	$(RAILS_CMD) db:create;			# Create DB if doesn't exists
	$(RAILS_CMD) db:migrate;		# Create tables and relations - Used for version control

db-clear:
	$(RAKE_CMD) db:clear RAILS_ENV=$(ENV);

db-migrate:
	$(RAKE_CMD) db:migrate RAILS_ENV=$(ENV);

db-seed:
	$(RAKE_CMD) db:seed RAILS_ENV=$(ENV);

build:
ifeq ($(wildcard /.dockerenv),)
	docker-compose build
endif

run:
ifeq ($(wildcard /.dockerenv),)
	docker-compose up
endif

start:
ifeq ($(wildcard /.dockerenv),)
	docker-compose up -d
endif

stop:
ifeq ($(wildcard /.dockerenv),)
	docker-compose stop
endif

restart:
ifeq ($(wildcard /.dockerenv),)
	docker-compose restart
endif

rm-containers:
ifeq ($(wildcard /.dockerenv),)
	docker rm $(shell docker stop $(APP_CONTAINER_NAME) $(DATABASE_CONTAINER_NAME))
endif

clean-images:
ifeq ($(wildcard /.dockerenv),)
	docker rmi $(shell docker images -q -f "dangling=true")
endif

rebuild:
	(${MAKE} rm-containers || ${MAKE} clean-images || true) && ${MAKE} build

enter:
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l

enter-db:
	docker exec -it $(DATABASE_CONTAINER_NAME) /bin/bash -l

# Create docker network bridge
network:
	docker network create -d bridge msbridge

status:
ifeq ($(wildcard /.dockerenv),)
ifeq ($(DOCKER_APP_CONTAINER_ID),)
	@echo "$(RED)APP container is not running$(NC)"
else
	@echo "$(GREEN)APP container is running$(NC)"
endif
endif

s: server
server: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l -c "make server";
else
	TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) $(RAILS_CMD) s -b 0.0.0.0 -p 3000 #TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) bundle exec puma -b tcp://0.0.0.0 -p 3000
	
endif

c: console
console: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l -c "make console";
else
	TRUSTED_IP=$(DOCKER_HOST_IP) RAILS_ENV=$(ENV) $(RAILS_CMD) c
endif

b: bundle
bundle: start
ifeq ($(wildcard /.dockerenv),)
	docker exec -it $(APP_CONTAINER_NAME) /bin/bash -l -c "make script";
else
	/bin/bash -l -c /etc/my_init.d/0000_init_container.sh;
endif