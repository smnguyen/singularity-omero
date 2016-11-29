#!/usr/bin/env bash

export PGPASSWORD=omero
export PG_PORT=5432
export OMERO_ADMIN_PASSWORD=password

export PGDATA=/omero/postgres

if [ ! -f $PGDATA/PG_VERSION ]; then
	echo "Initializing database..."

	initdb --locale en_US.utf8

	# Launch Postgres in a way that doesn't accept any connections unless the socket is known.
	# This prevents OMERO.server from connecting to the database before it's fully setup.
	SOCKET=/tmp/pg_socket
	mkdir -p $SOCKET
	PGHOST=$SOCKET pg_ctl -o "-c listen_addresses='' -c unix_socket_directories='$SOCKET'" -w start

	PGHOST=$SOCKET psql --username $USER -d postgres <<-EOSQL
		CREATE USER omero WITH SUPERUSER PASSWORD 'PGPASSWORD';
	EOSQL
	PGHOST=$SOCKET createdb -O omero omero

	INIT_FILE=/tmp/omero.sql
	omero db script -f $INIT_FILE --password "$OMERO_ADMIN_PASSWORD"
	PGHOST=$SOCKET psql -U omero -d omero -f $INIT_FILE
	rm $INIT_FILE

	PGHOST=$SOCKET pg_ctl -m fast -w stop
fi

exec postgres -p $PG_PORT
