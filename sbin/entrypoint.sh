#!/bin/bash

set -e

[ ! -z "$STANDBY_IMAGE_URL" ] && curl $STANDBY_IMAGE_URL > /etc/nginx/standby.png

render-templates.sh /etc/nginx/templates/ /etc/nginx/
exec $@
