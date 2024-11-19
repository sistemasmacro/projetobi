include help.mk
.PHONY: guard-%
guard-%: ##@other Check if variables exists.
	@ if [ "${${*}}" = ""  ]; then \
		echo "Variable '$*' not set"; \
		exit 1; \
	fi

MAKEFLAGS += --silent

# Directories to create if they don't exist
DIRECTORIES := dags dbt logs meltano plugins key dbt_logs dbt_target dbt_packages

.PHONY: help
help:
	@./hack/base/bin/help

# Create directories if they don't exist
$(foreach dir,$(DIRECTORIES),$(if $(wildcard $(dir)),,$(shell mkdir -p $(dir))))
.PHONY: build
build: create-dirs ##@Commands Build docker image bi_airflow
	# @./hack/create_pip_conf.sh
	@docker compose down
	@docker compose build --no-cache
	@docker compose --profile build_only build meltano --no-cache
	@docker network create airflow-network
	@docker image prune -f

## Uses docker compose to upload the airflow environment and the other necessary containers
.PHONY: up 
up: create-dirs
	@docker compose down
	@docker compose up --force-recreate

## Stop all containers
.PHONY: down
down:
	@docker compose down

## Publish the built bi_airflow image
.PHONY: push
push:  ##@Commands Publish the built bi_airflow image
	@echo "Push docker registry.neoway.com.br/bi/bi_airflow:latest image in registry."
	@docker compose push

## Create directories if they don't exist
.PHONY: create-dirs
create-dirs:
	@$(foreach dir,$(DIRECTORIES),$(if $(wildcard $(dir)),,$(shell mkdir -p $(dir))))