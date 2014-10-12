FROM ubuntu:14.04
MAINTAINER Reid Burke <me@reidburke.com>

RUN apt-get -q -y update \
    && apt-get -q -y install cron logrotate make build-essential libssl-dev \
        zlib1g-dev libpcre3 libpcre3-dev curl pgp yasm \
    && apt-get -q -y build-dep nginx \
    && apt-get -q -y clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

RUN cd /root \
    && curl -L http://downloads.sourceforge.net/project/opencore-amr/fdk-aac/fdk-aac-0.1.3.tar.gz > fdk-aac.tgz \
    && mkdir fdk-aac && tar xzf fdk-aac.tgz -C fdk-aac --strip 1 && cd fdk-aac \
    && ./configure && make install

RUN cd /root && curl -L -O ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2 \
    && mkdir x264 && tar xjf last_x264.tar.bz2 -C x264 --strip 1 && cd x264 \
    && ./configure --enable-static && make install

RUN cd /root && curl -L -O https://libav.org/releases/libav-11.tar.gz \
    && mkdir libav && tar xzf libav-11.tar.gz -C libav --strip 1 && cd libav \
    && ./configure --enable-gpl --enable-nonfree \
        --enable-libfdk-aac --enable-libx264 \
    && make install

RUN groupadd nginx
RUN useradd -m -g nginx nginx
RUN mkdir -p /var/log/nginx /var/cache/nginx

RUN cd /root && curl -L https://github.com/arut/nginx-rtmp-module/tarball/5fb4c99ca93442c571354af6a40a4f3ef736af57 > nginx-rtmp.tgz \
    && mkdir nginx-rtmp && tar xzf nginx-rtmp.tgz -C nginx-rtmp --strip 1 

RUN mkdir /www && cp /root/nginx-rtmp/stat.xsl /www/info.xsl && chown -R nginx:nginx /www

RUN cd /root \
    && curl -L -O http://nginx.org/download/nginx-1.7.5.tar.gz \
    && curl -L -O http://nginx.org/download/nginx-1.7.5.tar.gz.asc \
    && gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-key A1C052F8 \
    && gpg nginx-1.7.5.tar.gz.asc \
    && tar xzf nginx-1.7.5.tar.gz && cd nginx-1.7.5 \
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

ADD nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 1935

CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf"]
