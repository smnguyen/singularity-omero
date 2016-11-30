#!/usr/bin/env bash

omero config set omero.web.application_server.port $WEB_PORT
omero config set omero.web.server_list "[[\"localhost\", $SSL_PORT, \"omero\"]]"
exec omero web start --foreground
