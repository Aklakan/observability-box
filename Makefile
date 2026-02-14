#!/usr/bin/make

SHELL = /bin/bash

COMPOSE_FILE = docker-compose.yaml
ENV_FILE = .env

.PHONY: help up stop down logs logsf

.ONESHELL:
help: ## Show these help instructions.
	@sed -rn 's/^([a-zA-Z0-9_./| -]+):.*?## (.*)$$/"\1" "\2"/p' < $(MAKEFILE_LIST) | xargs printf "make %-30s # %s\n"

up: .env ## Start the container with the current user's UID and GID.
	@USER_ID=$(shell awk -F= '/^USER_ID=/{print $$2}' $(ENV_FILE))
	@GROUP_ID=$(shell awk -F= '/^GROUP_ID=/{print $$2}' $(ENV_FILE))
	# @read -n 1 -p "About to run container as $${USER_ID}:$${GROUP_ID} (sourced from $(ENV_FILE)) - Press [Enter] to continue or [CTRL+C] to abort."
	docker compose -f $(COMPOSE_FILE) up -d

stop: | .env ## Stop a container (if it is running).
	docker compose -f $(COMPOSE_FILE) stop

down: | .env ## Stop a container (if it is running).
	docker compose -f $(COMPOSE_FILE) down

logs: | .env ## Show logs.
	# SERVICE=$(shell docker compose -f $(COMPOSE_FILE) config --services)
	@docker compose -f $(COMPOSE_FILE) logs

logsf: | .env ## Follow logs (logs -f).
	@docker compose -f $(COMPOSE_FILE) logs -f

.env: ## Generate or overwrite an existing .env file.
	@echo "Generating new file: $(ENV_FILE)"
	@echo "USER_ID=$(shell id -u)" > $(ENV_FILE)
	@echo "GROUP_ID=$(shell id -g)" >> $(ENV_FILE)

