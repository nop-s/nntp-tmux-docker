DOCKERBUILD  ?= docker-compose build
GOBUILDLINUX ?= GGO_ENABLED=1 GOOS=linux go build -a
BINDIR 	   := $(CURDIR)/bin
COMMIT     := $(shell git rev-parse --short HEAD)
BUILD_DATE := $(shell date +%Y%m%d%H%M%S)

if fi\
.PHONY: preq
preq:
ifeq (,$(wildcard .env))
	$(error "Setup your Docker .env file first…")
	exit 1
endif	

.PHONY: db
db: preq
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
all: network db newznab-tmux

.PHONY: clean
clean:
	docker network prune -f
	docker container prune -f

