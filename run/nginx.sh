#!/usr/bin/env bash

while [ ! -f /omero/var/django.pid ]; do
  # We need to wait here so /omero/run/web.sh can set omero.web.application_server.port,
  # so that the nginx config below is generated correctly.
  echo "Waiting for OMERO.web to be up."
  sleep 5s
done

omero web config nginx --http $HTTP_PORT > /etc/nginx/sites-available/omero.conf
rm -f /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/omero.conf /etc/nginx/sites-enabled/

exec nginx -g "daemon off;" -c /omero/run/nginx.conf
