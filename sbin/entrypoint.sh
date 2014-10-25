#!/bin/bash

set -eu

render-templates.sh /etc/nginx/templates/ /etc/nginx/
exec $@
