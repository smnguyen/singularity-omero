#!/usr/bin/env bash

export OMERO_PG_PASSWORD=omero

while ! pg_isready -d omero -U omero --quiet; do
    echo "Waiting for database to be up."
    sleep 5s
done

omero config set omero.db.host localhost
omero config set omero.db.port 5432  # Make this configurable
omero config set omero.db.name omero
omero config set omero.db.user omero
omero config set omero.db.pass $OMERO_PG_PASSWORD
omero config set omero.data.dir /omero/data

exec omero admin start --foreground
