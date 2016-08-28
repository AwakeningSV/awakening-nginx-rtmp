# awakening-nginx-rtmp

Live streaming video server for Flash, iOS and Android

## Configuration with environment variables

You must set the `LIVE_SECRET`.

 - `LIVE_SECRET`: Secret token for publishing and statistics.

**Other settings are optional and considered experimental.**
They are under active development and may change or be removed.

The variants option allows for customization beyond the default encoder settings:

 - `LIVE_VARIANTS_{name}`: Represents video and audio transcoding
    rates and the associated HLS variant bandwidth.
    These settings will depend on your hardware capability and desired quality.
    The format is `{video_kbps}:{audio_kbps}:{bandwidth_bps}`.
    For full details, see `templates/nginx.conf.tmpl` and refer to the nginx-rtmp
    documentation.

The downstreams option allows for copying an incoming RTMP stream to another server,
e.g. Facebook.

 - `LIVE_DOWNSTREAMS_{name}`: Corresponds to an RTMP URL that will recieve a copy of
    the incoming stream. _You should only accept a single stream if you use this setting._

The CORS setting allows for cross-origin requests from another frontend server.

 - `LIVE_CORS`: HTTP origin regex to allow CORS on the /hls location.

This image exposes ports `80` for HTTP and `1935` for RTMP.

### Example

    docker run -e LIVE_SECRET=VERY_SECRET_KEY
               -e LIVE_VARIANTS_LOW=128:64:192000
               -e LIVE_VARIANTS_MED=512:128:640000
               -p 80:80 -p 1935:1935 awakening/awakening-nginx-rtmp

## Dynamic configuration reloading with etcd

**This feature is experimental.** It may change or be removed.

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
