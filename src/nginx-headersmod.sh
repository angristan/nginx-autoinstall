#!/bin/bash
NGINX_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/nginx)
HEADERMOD_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/headermod)
# Dependencies
apt-get install build-essential ca-certificates libpcre3 libpcre3-dev autoconf automake libtool tar git libssl-dev -y
#Headers More
cd /opt
# Cleaning up in case of update
rm -r headers-more-nginx-module-${HEADERMOD_VER}
wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERMOD_VER}.tar.gz
tar xzf v${HEADERMOD_VER}.tar.gz
rm v${HEADERMOD_VER}.tar.gz
# Nginx
rm -r /opt/nginx-${NGINX_VER}
cd /opt
wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxf -
cd nginx-${NGINX_VER}
./configure \
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
        --user=www-data \
        --group=www-data \
        --with-threads \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-ipv6 \
        --with-http_mp4_module \
        --with-http_auth_request_module \
        --with-http_slice_module \
        --with-file-aio \
        --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security' \
        --add-module=/opt/headers-more-nginx-module-${HEADERMOD_VER}
make -j $(nproc)
make install
