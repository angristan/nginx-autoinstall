#!/bin/bash

# Check root access
if [[ "$EUID" -ne 0 ]]; then
	echo "Sorry, you need to run this as root"
	exit 1
fi

clear
echo "Welcome, to the nginx-autoinstall script."
echo "This script will install the latest Nginx Mainline version (1.9.12) with some optional famous modules."
echo ""
echo "Please tell me which modules you want to install."
echo "If you select none, Nginx will be installed with its default modules."
echo ""
echo "Modules to install :"
while [[ $LIBRESSL !=  "y" && $LIBRESSL != "n" ]]; do
		read -p "	LibreSSL [y/n]: " -e LIBRESSL
done
while [[ $PAGESPEED !=  "y" && $PAGESPEED != "n" ]]; do
		read -p "	PageSpeed [y/n]: " -e PAGESPEED
done
while [[ $BROTLI !=  "y" && $BROTLI != "n" ]]; do
		read -p "	Brotli [y/n]: " -e BROTLI
done
echo ""
read -n1 -r -p "Nginx is ready to be installed, press any key to continue..."

# Dependencies
apt-get install build-essential ca-certificates wget libpcre3 libpcre3-dev autoconf unzip automake libtool tar git libssl-dev -y

# LibreSSL
if [[ "$LIBRESSL" = 'y' ]]; then
	LIBRESSL_VER=2.3.2
	cd /opt
	# Cleaning up in case of update
	rm -r /opt/libressl-${LIBRESSL_VER}
	mkdir /opt/libressl-${LIBRESSL_VER}
	cd /opt/libressl-${LIBRESSL_VER}
	# LibreSSL download
	wget -qO- http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VER}.tar.gz | tar xz --strip 1
	./configure \
		LDFLAGS=-lrt \
		CFLAGS=-fstack-protector-strong \
		--prefix=/opt/libressl-${LIBRESSL_VER}/.openssl/ \
		--enable-shared=no
	# LibreSSL install
	make install-strip -j $(nproc)
fi

# PageSpeed
if [[ "$PAGESPEED" = 'y' ]]; then
	NPS_VER=1.10.33.6
	cd /opt
	# Cleaning up in case of update
	rm -r /opt/ngx_pagespeed-release-${NPS_VER}-beta
	cd /opt/
	# Download and extract of PageSpeed module
	wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VER}-beta.zip
	unzip release-${NPS_VER}-beta.zip
	rm release-${NPS_VER}-beta.zip
	cd ngx_pagespeed-release-${NPS_VER}-beta
	wget https://dl.google.com/dl/page-speed/psol/${NPS_VER}.tar.gz
	tar -xzvf ${NPS_VER}.tar.gz
	rm ${NPS_VER}.tar.gz
fi

#Brotli
if [[ "$BROTLI" = 'y' ]]; then
	cd /opt
	# Cleaning up in case of update
	rm -r libbrotli
	# libbrolti is needed for the ngx_brotli module
	# libbrotli download
	git clone https://github.com/bagder/libbrotli
	cd libbrotli
	./autogen.sh
	./configure
	make -j $(nproc)
	# libbrotli install
	make install
	# Linking libraries to avoid errors
	ldconfig
	# ngx_brotli module download
	cd /opt
	git clone https://github.com/google/ngx_brotli
fi

NGINX_VER=1.9.12
# Cleaning up in case of update
rm -r /opt/nginx-${NGINX_VER}
# Download and extract of Nginx source code
cd /opt/
wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxf -
cd nginx-${NGINX_VER}

# As the default nginx.conf does not work
# We download a clean and working conf from my GitHub.
# We do it only if it does not already exist (in case of update for instance)
if [[ ! -e /etc/nginx/nginx.conf ]]; then
	mkdir -p /etc/nginx
	cd /etc/nginx
	wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.conf
fi
cd /opt/nginx-${NGINX_VER}

# Modules configuration
# Common configuration 
NGINX_OPTIONS="--prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --user=nginx --group=nginx"
NGINX_MODULES="--without-http_ssi_module --without-http_scgi_module --without-http_uwsgi_module --without-http_fastcgi_module --without-http_geo_module --without-http_map_module --without-http_split_clients_module --without-http_memcached_module --without-http_empty_gif_module --without-http_browser_module --with-threads --with-file-aio --with-http_ssl_module --with-http_v2_module --with-ipv6 --with-http_mp4_module --with-http_auth_request_module --with-http_slice_module"

# No module
if [[ "$LIBRESSL" = 'n' ]] && [[ "$PAGESPEED" = 'n' ]] && [[ "$BROTLI" = 'n' ]]; then
	./configure $NGINX_OPTIONS $NGINX_MODULES
make -j $(nproc)
make install
fi

# All modules (LibreSSL + PageSpeed + Brotli)
if [[ "$LIBRESSL" = 'y' ]] && [[ "$PAGESPEED" = 'y' ]] && [[ "$BROTLI" = 'y' ]]; then
	# Fix for Nginx 1.9.12 and LibreSSL 2.3.2
	sed -i -e "s/install_sw/install/g" auto/lib/openssl/make
	./configure $NGINX_OPTIONS $NGINX_MODULES --with-openssl=/opt/libressl-${LIBRESSL_VER} --add-module=/opt/ngx_pagespeed-release-${NPS_VER}-beta --add-module=/opt/ngx_brotli
	make -j $(nproc)
	make install
fi

# LibreSSL 
if [[ "$LIBRESSL" = 'y' ]] && [[ "$PAGESPEED" = 'n' ]] && [[ "$BROTLI" = 'n' ]]; then
	# Fix for Nginx 1.9.12 and LibreSSL 2.3.2
	sed -i -e "s/install_sw/install/g" auto/lib/openssl/make
	./configure $NGINX_OPTIONS $NGINX_MODULES --with-openssl=/opt/libressl-${LIBRESSL_VER} 
	make -j $(nproc)
	make install
fi

# PageSpeed
if [[ "$LIBRESSL" = 'n' ]] && [[ "$PAGESPEED" = 'y' ]] && [[ "$BROTLI" = 'n' ]]; then
	./configure $NGINX_OPTIONS $NGINX_MODULES --add-module=/opt/ngx_pagespeed-release-${NPS_VER}-beta
	make -j $(nproc)
	make install
fi

# Brotli
if [[ "$LIBRESSL" = 'n' ]] && [[ "$PAGESPEED" = 'n' ]] && [[ "$BROTLI" = 'y' ]]; then
	./configure $NGINX_OPTIONS $NGINX_MODULES --add-module=/opt/ngx_brotli
	make -j $(nproc)
	make install
fi

# LibreSSL + PageSpeed
if [[ "$LIBRESSL" = 'y' ]] && [[ "$PAGESPEED" = 'y' ]] && [[ "$BROTLI" = 'n' ]]; then
	# Fix for Nginx 1.9.12 and LibreSSL 2.3.2
	sed -i -e "s/install_sw/install/g" auto/lib/openssl/make
	./configure $NGINX_OPTIONS $NGINX_MODULES --with-openssl=/opt/libressl-${LIBRESSL_VER} --add-module=/opt/ngx_pagespeed-release-${NPS_VER}-beta
	make -j $(nproc)
	make install
fi

# LibreSSL + Brotli
if [[ "$LIBRESSL" = 'y' ]] && [[ "$PAGESPEED" = 'n' ]] && [[ "$BROTLI" = 'y' ]]; then
	# Fix for Nginx 1.9.12 and LibreSSL 2.3.2
	sed -i -e "s/install_sw/install/g" auto/lib/openssl/make
	./configure $NGINX_OPTIONS $NGINX_MODULES --with-openssl=/opt/libressl-${LIBRESSL_VER} --add-module=/opt/ngx_brotli
	make -j $(nproc)
	make install
fi

# PageSpeed + Brotli
if [[ "$LIBRESSL" = 'n' ]] && [[ "$PAGESPEED" = 'y' ]] && [[ "$BROTLI" = 'y' ]]; then
	./configure $NGINX_OPTIONS $NGINX_MODULES --add-module=/opt/ngx_pagespeed-release-${NPS_VER}-beta --add-module=/opt/ngx_brotli
	make -j $(nproc)
	make install
fi

# Nginx installation from source does not add an init script for systemd.
# Using the official systemd script from nginx.org
if [[ ! -e /lib/systemd/system/nginx.service ]]; then
	cd /lib/systemd/system/
	wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.service
fi

# Restart Nginx
systemctl restart nginx

# We're done !
echo "Installation succcessful !"
