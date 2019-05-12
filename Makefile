DOCKERBUILD  ?= docker-compose build
COMMIT     := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date +%Y%m%d%H%M%S)
BUILD_DIR  := $(shell pwd)
SCRATCH_DIR := ${BUILD_DIR}/scratch.d
DB_DIR     := ${SCRATCH_DIR}/db
if fi\
.PHONY: preq
preq:
ifeq (,$(wildcard .env))
	$(error "Setup your Docker .env file first…")
	exit 1
endif	
ifeq (,$(wildcard ${SCRATCH_DIR}))
	mkdir -p ${DB_DIR}
endif
.PHONY: schema
schema: preq
	(bash DockerInit.d/make_schema.sh .env ${DB_DIR})

.PHONY: db
db: preq schema
	$(DOCKERBUILD) db
	(docker tag newznab/mariadb newznabtmux/mariadb:${BUILD_DATE})

.PHONY: newznab-tmux
newznab-tmux: preq
	$(DOCKERBUILD) newznab-tmux
	(docker tag newznab/newznab-tmux newznabtmux/newznab-tmux:${BUILD_DATE})

.PHONY: network
network: preq
	docker network create newznab_tmux_network

.PHONY: all
all: network db schema newznab-tmux

.PHONY: clean
clean:
	docker network prune -f
	docker container prune -f
	rm -rf ${BUILD_DIR}/scratch.d

