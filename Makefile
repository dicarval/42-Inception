include ./srcs/.env

all : up

up :
	@echo "Creating volume directories"
	@mkdir -p /home/$(USER)/data/$(USER)$(DOMAIN_SUFFIX)/mariadb
	@mkdir -p /home/$(USER)/data/$(USER)$(DOMAIN_SUFFIX)/wordpress
	@mkdir -p /home/$(USER)/data/$(USER)$(DOMAIN_SUFFIX)/redis

	@echo "Building the containers"
	@docker compose --env-file /home/dicarval/data/.env -f ./srcs/docker-compose.yml up

down :
	@echo "Removing Inception containers"
	@docker compose -f ./srcs/docker-compose.yml down --rmi all -v
	@echo "Deleting directories"
	@sudo rm -rf /home/$(USER)/data/$(USER)$(DOMAIN_SUFFIX)
	@echo "All clean"

recreate : down up

stop :
	@echo "Stoping Inception containers"
	@docker compose -f ./srcs/docker-compose.yml stop

start :
	@echo "Starting Inception containers"
	@docker compose -f ./srcs/docker-compose.yml start

status :
	@docker ps
