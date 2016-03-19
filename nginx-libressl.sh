NGINX_VER=1.9.12
LIBRESSL_VER=2.3.2
apt-get install build-essential ca-certificates libpcre3 libpcre3-dev tar libssl-dev -y
cd /opt
rm -r /opt/libressl-$LIBRESSL_VER
mkdir /opt/libressl-$LIBRESSL_VER
cd /opt/libressl-$LIBRESSL_VER
wget -qO- http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-$LIBRESSL_VER.tar.gz | tar xz --strip 1
./configure \
	LDFLAGS=-lrt \
	CFLAGS=-fstack-protector-strong \
	--prefix=/opt/libressl-$LIBRESSL_VER/.openssl/ \
	--enable-shared=no
make install-strip -j $(nproc)
rm -r /opt/nginx-$NGINX_VER
cd /opt
wget -qO- http://nginx.org/download/nginx-$NGINX_VER.tar.gz | tar zxf -
cd nginx-$NGINX_VER
# Fix for Nginx 1.9.12
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
	--with-threads \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-ipv6 \
	--with-http_mp4_module \
	--with-http_auth_request_module \
	--with-http_slice_module \
	--with-file-aio \
	--with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security' \
	--with-openssl=/opt/libressl-$LIBRESSL_VER
make -j $(nproc)
make install
