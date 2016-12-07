#!/usr/bin/env bash

omero config set omero.web.application_server.port $WEB_PORT
omero config set omero.web.server_list "[[\"localhost\", $SSL_PORT, \"omero\"]]"

# Daily task to clean up sessions
# https://www.openmicroscopy.org/site/support/omero5.2/sysadmins/unix/install-web.html#omero-web-maintenance-unix-linux
omero web clearsessions

exec omero web start --foreground
