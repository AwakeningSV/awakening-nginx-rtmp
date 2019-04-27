# awakening-nginx-rtmp

Live streaming video server for Flash, iOS and Android

## Configuration with environment variables

You must set the following environment variables:

 - `LIVE_SECRET`: Secret token for publishing and statistics.
 - `LIVE_ENCODINGS_{name}`: You must set one or more of these variables
    that represent the transcoding rates and HLS variant bandwidth.
    These settings will depend on your hardware capability and desired quality.
    The format is `{video_kilobits}:{audio_kilobits}:{bandwidth}:{scale}`.
    For full details, see `templates/nginx.conf.tmpl` and refer to the nginx-rtmp
    documentation.

These settings are optional:

 - `LIVE_DOWNSTREAMS_{name}`: Corresponds to an RTMP URL that will recieve a copy of
    the incoming stream. _You should only accept a single stream if you use this setting._
 - `LIVE_CORS`: HTTP origin regex to allow CORS on the /hls location.

This image exposes ports `80` for HTTP and `1935` for RTMP.

### Example

    docker run -e LIVE_SECRET=VERY_SECRET_KEY
               -e LIVE_ENCODINGS_LOW=128:64:160000
               -e LIVE_ENCODINGS_MED=512:128:640000
               -p 80:80 -p 1935:1935 awakening/awakening-nginx-rtmp

## Dynamic configuration reloading with etcd

If `ETCD_URL` is provided, configuration is expected to come from the etcd service.

The configuration is the same as above, except they correspond to etcd keys like `/live/cors`,
`/live/secret`, `/live/downstreams/example`, etc.

The container will poll for changes every 10 seconds. If changes are detected,
nginx will be reloaded with new configuration.

## Publish URL

Set your RTMP encoder to publish to `rtmp://{your-server}/pub_{PUBLISH_SECRET}/{your-stream-name}`.

## Player URL

The stream can be viewed at `rtmp://{your-server}/player/{your-stream-name}`.

## HLS

HLS playlists are available at `http://{{your-server}/hls/{your-stream-name}.m3u8`.

## Statistics

The following resources are available:

 - `info`: General information
 - `stats`: XML of general information

Statistic URLs contain references to the `PUBLISH_SECRET`, so they are protected.
You can visit these protected resources by visiting `/p/{token}/{resource-name}`, where
`{token}` is set the the result of:

```
echo -n '{resource-name}{PUBLISH_SECRET}' | openssl md5 -hex
```

## Deprecated environment variables

These environment variables are deprecated.
They still work but may be removed in the future.

 - `PUBLISH_SECRET`, use `LIVE_SECRET` instead
 - `HTTP_CORS_ORIGIN`, use `LIVE_CORS` instead

## License

MIT, see LICENSE file.
