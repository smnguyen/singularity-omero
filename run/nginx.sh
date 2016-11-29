#!/usr/bin/env bash

export HTTP_PORT=8080

omero web config nginx --http $HTTP_PORT > /etc/nginx/sites-available/omero.conf
rm -f /etc/nginx/sites-enabled/*
ln -s /etc/nginx/sites-available/omero.conf /etc/nginx/sites-enabled/

exec nginx -g "daemon off;" -c /omero/run/nginx.conf
