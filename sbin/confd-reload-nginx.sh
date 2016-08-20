#!/bin/bash

if [ -s /var/run/nginx.pid ]; then
    echo "confd-reload-nginx.sh: reloading nginx..."
    /usr/sbin/nginx -s reload
else
    echo "confd-reload-nginx.sh: ignoring reload because nginx is not yet running"
fi