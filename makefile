# VARIABLES
DOCKER_LABEL_KEY := project
DOCKER_LABEL_VALUE := $(notdir $(patsubst %/,%,$(CURDIR)))
DOCKER_LABEL := $(DOCKER_LABEL_KEY)=$(DOCKER_LABEL_VALUE)

# EXECUTABLES
EXE_COMPOSE := docker compose

# FILES
FILE_COMPOSE := compose.yml
FILE_BACKEND := backend.yml
FILE_ENV_TEST := .env_test
FILE_ENV_PRIV := .env_priv

# PATH
PATH_COMPOSE := $(CURDIR)/$(FILE_COMPOSE)
PATH_BACKEND := $(CURDIR)/$(FILE_BACKEND)

PATH_ENV_TEST := $(CURDIR)/$(FILE_ENV_TEST)
PATH_ENV_PRIV := $(CURDIR)/$(FILE_ENV_PRIV)

# COMMANDS
CMD_COMPOSE := LABEL_KEY="$(DOCKER_LABEL_KEY)" LABEL_VALUE="$(DOCKER_LABEL_VALUE)" $(EXE_COMPOSE) -f $(PATH_COMPOSE) --env-file $(PATH_ENV_TEST) --env-file $(PATH_ENV_PRIV)
CMD_CONTAINERS := docker ps -aq --filter "label=$(DOCKER_LABEL)"

.PHONY: prune
prune:
	@docker stop $(shell $(CMD_CONTAINERS)) 2>/dev/null || true
	@docker rm -f $(shell $(CMD_CONTAINERS)) 2>/dev/null || true
	@docker volume prune -f $(shell $(CMD_CONTAINERS)) 2>/dev/null || true
	@docker network prune -f $(shell $(CMD_CONTAINERS)) 2>/dev/null || true
	@docker image prune -f $(shell $(CMD_CONTAINERS)) 2>/dev/null || true

backend:
	-@($(CMD_COMPOSE) up -d backend)
	-@($(CMD_COMPOSE) up -d backend-init)

fmt: prune
	-@($(CMD_COMPOSE) up fmt)

init: fmt backend
	-@($(CMD_COMPOSE) up init)

apply: init
	-@($(CMD_COMPOSE) up apply)

destroy: fmt 
	-@($(CMD_COMPOSE) up destroy)
