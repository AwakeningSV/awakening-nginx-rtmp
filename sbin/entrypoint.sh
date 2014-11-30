#!/bin/bash

set -e

render-templates.sh /etc/nginx/templates/ /etc/nginx/
exec $@
