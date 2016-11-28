.PHONY: _run _shell build run purge setup shell

_run:
	singularity run -B "./data:/omero/data" -B "./logs:/omero/logs" -B "./postgres:/omero/postgres" -B "./run":/omero/run -B "./user_scripts:/omero/user_scripts" -w omero.img

_shell:
	singularity shell -B "./data:/omero/data" -B "./logs:/omero/logs" -B "./postgres:/omero/postgres" -B "./run":/omero/run -B "./user_scripts:/omero/user_scripts" -w omero.img

build:
	singularity create --size 4096 omero.img && singularity bootstrap omero.img omero.def

purge:
	rm -rf data/*
	rm -rf logs/*
	rm -rf postgres/*
	rm -rf user_scripts/*

run: setup _run

setup:
	mkdir -p data
	mkdir -p logs
	mkdir -p postgres
	mkdir -p user_scripts

shell: setup _shell
