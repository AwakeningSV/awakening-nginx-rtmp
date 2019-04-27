FROM ubuntu:18.04
MAINTAINER Reid Burke <reid@awakeningchurch.com>

RUN echo "deb-src http://archive.ubuntu.com/ubuntu/ bionic main restricted" >> /etc/apt/sources.list \
    && apt-get -qy update \
    && apt-get -qy install cron logrotate make build-essential libssl-dev \
        zlib1g-dev libpcre3 libpcre3-dev curl pgp nasm librtmp-dev \
    && apt-get -qy build-dep nginx \
    && apt-get -qy clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN cd /root \
    && curl -L https://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-2.0.0.tar.gz > fdk-aac.tgz \
    && mkdir fdk-aac && tar xzf fdk-aac.tgz -C fdk-aac --strip 1 && cd fdk-aac \
    && ./configure && make install

RUN cd /root \
    && curl -L ftp://ftp.videolan.org/pub/x264/snapshots/x264-snapshot-20190331-2245.tar.bz2 > x264.tar.bz2 \
    && mkdir x264 && tar xjf x264.tar.bz2 -C x264 --strip 1 && cd x264 \
    && ./configure --enable-static && make install

RUN cd /root \
    && curl -L https://ffmpeg.org/releases/ffmpeg-4.1.tar.bz2 > ffmpeg.tgz \
    && mkdir ffmpeg && tar xjf ffmpeg.tgz -C ffmpeg --strip 1 && cd ffmpeg \
    && ./configure --enable-gpl --enable-nonfree \
        --enable-libfdk_aac --enable-libx264 --enable-librtmp \
    && make install

RUN groupadd nginx
RUN useradd -m -g nginx nginx
RUN mkdir -p /var/log/nginx /var/cache/nginx

RUN cd /root && curl -L https://github.com/arut/nginx-rtmp-module/archive/v1.2.1.tar.gz > nginx-rtmp.tgz \
    && mkdir nginx-rtmp && tar xzf nginx-rtmp.tgz -C nginx-rtmp --strip 1 

RUN mkdir /www && cp /root/nginx-rtmp/stat.xsl /www/info.xsl && chown -R nginx:nginx /www

RUN cd /root \
    && curl -L -O http://nginx.org/download/nginx-1.14.2.tar.gz \
    && curl -L -O http://nginx.org/download/nginx-1.14.2.tar.gz.asc \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key A1C052F8 \
    && gpg nginx-1.14.2.tar.gz.asc \
    && tar xzf nginx-1.14.2.tar.gz && cd nginx-1.14.2 \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/var/run/nginx.pid \
        --lock-path=/var/run/nginx.lock \
        --http-client-body-temp-path=/var/cache/nginx/client_temp \
        --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
        --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
        --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
        --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
        --user=nginx \
        --group=nginx \
        --with-http_ssl_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_sub_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_mp4_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_random_index_module \
        --with-http_secure_link_module \
        --with-http_stub_status_module \
        --with-http_auth_request_module \
        --with-mail \
        --with-mail_ssl_module \
        --with-file-aio \
        --add-module=/root/nginx-rtmp \
        --with-ipv6 \
   && make install

RUN cd /root && curl -L https://github.com/kelseyhightower/confd/releases/download/v0.12.0-alpha3/confd-0.12.0-alpha3-linux-amd64 > confd \
    && mv confd /usr/local/bin/confd && chmod +x /usr/local/bin/confd

ADD templates/nginx.conf.tmpl /etc/confd/templates/nginx.conf.tmpl
ADD conf.d/nginx.toml /etc/confd/conf.d/nginx.toml

RUN ldconfig

EXPOSE 80
EXPOSE 1935

ADD sbin/entrypoint.sh /usr/sbin/entrypoint.sh
ADD sbin/confd-reload-nginx.sh /usr/sbin/confd-reload-nginx.sh

ENTRYPOINT ["/usr/sbin/entrypoint.sh"]
CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
