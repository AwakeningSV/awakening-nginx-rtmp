#!/bin/bash

set -eo pipefail

echo "[awakening-nginx-rtmp] starting..."

if [ -z "$ETCD_URL" ]; then

    if ! compgen -A variable | grep LIVE_ENCODINGS >/dev/null; then
       echo "[awakening-nginx-rtmp] setting default LIVE_ENCODINGS because none were set"
       export LIVE_ENCODINGS_LOW=640x480:128:64:160000
       export LIVE_ENCODINGS_MED=640x480:512:128:640000
    fi

    if [ ! -z "$PUBLISH_SECRET" ]; then
        echo "[awakening-nginx-rtmp] PUBLISH_SECRET is deprecated, use LIVE_SECRET instead"
        export LIVE_SECRET="$PUBLISH_SECRET"
    fi

    if [ ! -z "$CORS_HTTP_ORIGIN" ]; then
        echo "[awakening-nginx-rtmp] CORS_HTTP_ORIGIN is deprecated, use LIVE_CORS instead"
        export LIVE_CORS="$CORS_HTTP_ORIGIN"
    fi

    echo "[awakening-nginx-rtmp] rendering configuration from environment variables..."
    confd -onetime -backend env

else

    until confd -onetime -node $ETCD_URL; do
        echo "[awakening-nginx-rtmp] waiting for etcd to populate configuration variables..."
        sleep 5
    done
    echo "[awakening-nginx-rtmp] monitoring etcd for changes..."
    confd -interval 10 -node $ETCD_URL &
fi

exec $@
