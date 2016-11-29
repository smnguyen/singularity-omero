.PHONY: _run _shell build run purge setup shell

_run:
	singularity run -B "./data:/omero/data" -B "./var:/omero/var" -B "./postgres:/omero/postgres" -B "./run":/omero/run -B "./user_scripts:/omero/user_scripts" -w omero.img

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
	rm -rf var/*
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
