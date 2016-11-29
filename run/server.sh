#!/usr/bin/env bash

export PGPASSWORD=omero
export PG_PORT=5432
export TCP_PORT=4063
export SSL_PORT=4064

while ! pg_isready -d omero -U omero --quiet; do
    echo "Waiting for database to be up."
    sleep 5s
done

omero config set omero.db.host localhost
omero config set omero.db.port $PG_PORT
omero config set omero.db.name omero
omero config set omero.db.user omero
omero config set omero.db.pass $PGPASSWORD

omero config set omero.data.dir /omero/data
omero config set omero.ports.tcp $TCP_PORT
omero config set omero.ports.ssl $SSL_PORT
# Set omero.ports.registry?

exec omero admin start --foreground
