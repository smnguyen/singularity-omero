.PHONY: _run _shell build run purge setup shell

PG_PORT ?= 5432
PGPASSWORD ?= omero
SERVER_REGISTRY_PORT ?= 4061
SERVER_TCP_PORT ?= 4063
SERVER_SSL_PORT ?= 4064
WEB_PORT ?= 4080
HTTP_PORT ?= 8080

_run:
	singularity run -B "./data:/omero/data" -B "./var:/omero/var" -B "./postgres:/omero/postgres" -B "./run":/omero/run -B "./user_scripts:/omero/user_scripts" -w omero.img --pg-port $(PG_PORT) --pg-password $(PGPASSWORD) --server-registry-port $(SERVER_REGISTRY_PORT) --server-tcp-port $(SERVER_TCP_PORT) --server-ssl-port $(SERVER_SSL_PORT) --web $(WEB_PORT) --http $(HTTP_PORT)

_shell:
	singularity shell -B "./data:/omero/data" -B "./var:/omero/var" -B "./postgres:/omero/postgres" -B "./run":/omero/run -B "./user_scripts:/omero/user_scripts" -w omero.img

build:
ifndef SUDO_USER
	echo "make build must be run with sudo"
	exit 1
endif
	singularity create --size 4096 omero.img
	singularity bootstrap omero.img omero.def
	chown $(SUDO_USER) omero.img

purge:
	rm -rf data/*
	rm -rf data/.omero
	rm -rf var/*
	mkdir -p var/log/supervisor
	mkdir -p var/log/nginx
	rm -rf postgres/*
	rm -rf user_scripts/*

run: setup _run

setup:
	mkdir -p data
	mkdir -p var/log/supervisor
	mkdir -p var/log/nginx
	mkdir -p postgres
	mkdir -p user_scripts

shell: setup _shell
