#!/bin/bash
apt-get install build-essential ca-certificates curl libpcre3 libpcre3-dev tar libssl-dev -y
NGINX_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/nginx)
LIBRESSL_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/libressl)
cd /opt
rm -r /opt/libressl-${LIBRESSL_VER}
mkdir /opt/libressl-${LIBRESSL_VER}
cd /opt/libressl-${LIBRESSL_VER}
wget -qO- http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VER}.tar.gz | tar xz --strip 1
./configure \
	LDFLAGS=-lrt \
	CFLAGS=-fstack-protector-strong \
	--prefix=/opt/libressl-${LIBRESSL_VER}/.openssl/ \
	--enable-shared=no
make install-strip -j $(nproc)
rm -r /opt/nginx-${NGINX_VER}
cd /opt
wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxf -
cd nginx-${NGINX_VER}
# Fix for Nginx 1.9.12 and LibreSSL 2.3.2
sed -i -e "s/install_sw/install/g" auto/lib/openssl/make
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
	--user=nginx \
	--group=nginx \
	--without-http_ssi_module \
	--without-http_scgi_module \
	--without-http_uwsgi_module \
	--without-http_geo_module \
	--without-http_split_clients_module \
	--without-http_memcached_module \
	--without-http_empty_gif_module \
	--without-http_browser_module \
	--with-threads \
	--with-file-aio \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-ipv6 \
	--with-http_mp4_module \
	--with-http_auth_request_module \
	--with-http_slice_module \
	--with-openssl=/opt/libressl-${LIBRESSL_VER}
make -j $(nproc)
make install
