#!/usr/bin/env bash

export WEB_PORT=4080
export SSL_PORT=4064

omero config set omero.web.application_server.port $WEB_PORT
omero config set omero.web.server_list "[[\"localhost\", $SSL_PORT, \"omero\"]]"
exec omero web start --foreground
