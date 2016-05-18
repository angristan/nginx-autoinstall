#!/bin/bash

# Colors
CSI="\033["
CEND="${CSI}0m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"

# Check root access
if [[ "$EUID" -ne 0 ]]; then
	echo -e "${CRED}Sorry, you need to run this as root${CEND}"
  	exit 1
fi

clear
echo "Welcome to the nginx-autoinstall script."
echo "This script will install the latest Nginx Mainline version with some optional famous modules."
echo ""
echo "Please tell me which modules you want to install."
echo "If you select none, Nginx will be installed with its default modules."
echo ""
echo "Modules to install :"
while [[ $LIBRESSL !=  "y" && $LIBRESSL != "n" ]]; do
        read -p "       LibreSSL [y/n]: " -e LIBRESSL
done
while [[ $PAGESPEED !=  "y" && $PAGESPEED != "n" ]]; do
        read -p "       PageSpeed [y/n]: " -e PAGESPEED
done
while [[ $BROTLI !=  "y" && $BROTLI != "n" ]]; do
        read -p "       Brotli [y/n]: " -e BROTLI
done
while [[ $HEADERMOD !=  "y" && $HEADERMOD != "n" ]]; do
        read -p "       Headers More [y/n]: " -e HEADERMOD
done
while [[ $GEOIP !=  "y" && $GEOIP != "n" ]]; do
        read -p "       GeoIP [y/n]: " -e GEOIP
done
echo ""
read -n1 -r -p "Nginx is ready to be installed, press any key to continue..."
echo ""

# Dependencies
echo -ne "       Installaling dependencies      [..]\r"
apt-get install build-essential ca-certificates wget curl libpcre3 libpcre3-dev autoconf unzip automake libtool tar git libssl-dev -y &>/dev/null

if [ $? -eq 0 ]; then
	echo -ne "       Installing dependencies        [${CGREEN}OK${CEND}]\r"
	echo -ne "\n"
else
	echo -e "        Installing dependencies      [${CRED}FAIL${CEND}]"
	exit 1
fi

# LibreSSL
if [[ "$LIBRESSL" = 'y' ]]; then
        LIBRESSL_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/libressl)
        cd /opt
        # Cleaning up in case of update
        rm -r libressl-${LIBRESSL_VER} &>/dev/null 
        mkdir libressl-${LIBRESSL_VER}
        cd libressl-${LIBRESSL_VER}
        # LibreSSL download
        echo -ne "       Downloading LibreSSL           [..]\r"
        wget -qO- http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VER}.tar.gz | tar xz --strip 1

		if [ $? -eq 0 ]; then
			echo -ne "       Downloading LibreSSL           [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading LibreSSL           [${CRED}FAIL${CEND}]"
			exit 1
		fi

		echo -ne "       Configuring LibreSSL           [..]\r"
        ./configure \
                LDFLAGS=-lrt \
                CFLAGS=-fstack-protector-strong \
                --prefix=/opt/libressl-${LIBRESSL_VER}/.openssl/ \
                --enable-shared=no &>/dev/null

        if [ $? -eq 0 ]; then
			echo -ne "       Configuring LibreSSL           [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Configuring LibreSSL         [${CRED}FAIL${CEND}]"
			exit 1
		fi

        # LibreSSL install
        echo -ne "       Installing LibreSSL            [..]\r"
        make install-strip -j $(nproc) &>/dev/null

		if [ $? -eq 0 ]; then
			echo -ne "       Installing LibreSSL            [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Installing LibreSSL            [${CRED}FAIL${CEND}]"
			exit 1
		fi
fi

# PageSpeed
if [[ "$PAGESPEED" = 'y' ]]; then
        NPS_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/pagespeed)
        cd /opt
        # Cleaning up in case of update
        rm -r ngx_pagespeed-release-${NPS_VER}-beta &>/dev/null 
        # Download and extract of PageSpeed module
        echo -ne "       Downloading ngx_pagespeed      [..]\r"
        wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VER}-beta.zip &>/dev/null
        unzip release-${NPS_VER}-beta.zip &>/dev/null
        rm release-${NPS_VER}-beta.zip
        cd ngx_pagespeed-release-${NPS_VER}-beta
        wget https://dl.google.com/dl/page-speed/psol/${NPS_VER}.tar.gz &>/dev/null
        tar -xzf ${NPS_VER}.tar.gz 
        rm ${NPS_VER}.tar.gz

        if [ $? -eq 0 ]; then
			echo -ne "       Downloading ngx_pagespeed      [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading ngx_pagespeed      [${CRED}FAIL${CEND}]"
			exit 1
		fi
fi

#Brotli
if [[ "$BROTLI" = 'y' ]]; then
        cd /opt
        # Cleaning up in case of update
        rm -r libbrotli &>/dev/null 
        # libbrolti is needed for the ngx_brotli module
        # libbrotli download
        echo -ne "       Downloading libbrotli          [..]\r"
        git clone https://github.com/bagder/libbrotli &>/dev/null

        if [ $? -eq 0 ]; then
			echo -ne "       Downloading libbrotli          [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading libbrotli          [${CRED}FAIL${CEND}]"
			exit 1
		fi

        cd libbrotli
        echo -ne "       Configuring libbrotli          [..]\r"
        ./autogen.sh &>/dev/null
        ./configure &>/dev/null

        if [ $? -eq 0 ]; then
			echo -ne "       Configuring libbrotli          [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Configuring libbrotli          [${CRED}FAIL${CEND}]"
			exit 1
		fi

		echo -ne "       Compiling libbrotli            [..]\r"
        make -j $(nproc) &>/dev/null

        if [ $? -eq 0 ]; then
			echo -ne "       Compiling libbrotli            [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Compiling libbrotli            [${CRED}FAIL${CEND}]"
			exit 1
		fi

        # libbrotli install
        echo -ne "       Installing libbrotli           [..]\r"
        make install &>/dev/null

        if [ $? -eq 0 ]; then
			echo -ne "       Installing libbrotli           [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Installing libbrotli           [${CRED}FAIL${CEND}]"
			exit 1
		fi

        # Linking libraries to avoid errors
        ldconfig &>/dev/null
        # ngx_brotli module download
        cd /opt
        rm -r ngx_brotli &>/dev/null 
        echo -ne "       Downloading ngx_brotli         [..]\r"
        git clone https://github.com/google/ngx_brotli &>/dev/null

        if [ $? -eq 0 ]; then
			echo -ne "       Downloading ngx_brotli         [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading ngx_brotli         [${CRED}FAIL${CEND}]"
			exit 1
		fi
fi

# More Headers
if [[ "$HEADERMOD" = 'y' ]]; then
        HEADERMOD_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/headermod)
        cd /opt
        # Cleaning up in case of update
        rm -r headers-more-nginx-module-${HEADERMOD_VER} &>/dev/null 
        echo -ne "       Downloading ngx_headers_more   [..]\r"
        wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERMOD_VER}.tar.gz &>/dev/null
        tar xzf v${HEADERMOD_VER}.tar.gz
        rm v${HEADERMOD_VER}.tar.gz
        
        if [ $? -eq 0 ]; then
			echo -ne "       Downloading ngx_headers_more   [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading ngx_headers_more   [${CRED}FAIL${CEND}]"
			exit 1
		fi
fi

# GeoIP
if [[ "$GEOIP" = 'y' ]]; then
        cd /opt
        # Cleaning up in case of update
        rm -r geoip-db &>/dev/null 
        mkdir geoip-db
        cd geoip-db
        echo -ne "       Downloading GeoIP databases    [..]\r"
		wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz &>/dev/null
		wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz &>/dev/null
		gunzip GeoIP.dat.gz
		gunzip GeoLiteCity.dat.gz
		mv GeoIP.dat GeoIP-Country.dat
		mv GeoLiteCity.dat GeoIP-City.dat
        
        if [ $? -eq 0 ]; then
			echo -ne "       Downloading GeoIP databases    [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading GeoIP databases    [${CRED}FAIL${CEND}]"
			exit 1
		fi
fi

NGINX_VER=$(curl -s https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/var/nginx)
# Cleaning up in case of update
rm -r /opt/nginx-${NGINX_VER} &>/dev/null
# Download and extract of Nginx source code
cd /opt/
echo -ne "       Downloading Nginx              [..]\r"
wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxf -
cd nginx-${NGINX_VER}

if [ $? -eq 0 ]; then
	echo -ne "       Downloading Nginx              [${CGREEN}OK${CEND}]\r"
	echo -ne "\n"
else
	echo -e "       Downloading Nginx              [${CRED}FAIL${CEND}]"
	exit 1
fi

# As the default nginx.conf does not work
# We download a clean and working conf from my GitHub.
# We do it only if it does not already exist (in case of update for instance)
if [[ ! -e /etc/nginx/nginx.conf ]]; then
        mkdir -p /etc/nginx
        cd /etc/nginx
        wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.conf &>/dev/null
fi
cd /opt/nginx-${NGINX_VER}

# Modules configuration
# Common configuration 
NGINX_OPTIONS="
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
--group=nginx"

NGINX_MODULES="--without-http_ssi_module \
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
--with-http_slice_module"

# Optional modules
# LibreSSL 
if [[ "$LIBRESSL" = 'y' ]]; then
        NGINX_MODULES=$(echo $NGINX_MODULES; echo --with-openssl=/opt/libressl-${LIBRESSL_VER})
fi

# PageSpeed
if [[ "$PAGESPEED" = 'y' ]]; then
        NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/opt/ngx_pagespeed-release-${NPS_VER}-beta")
fi

# Brotli
if [[ "$BROTLI" = 'y' ]]; then
        NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/opt/ngx_brotli")
fi

# More Headers
if [[ "$HEADERMOD" = 'y' ]]; then
        NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/opt/headers-more-nginx-module-${HEADERMOD_VER}")
fi

# GeoIP
if [[ "$GEOIP" = 'y' ]]; then
        NGINX_MODULES=$(echo $NGINX_MODULES; echo "--with-http_geoip_module")
fi

# We configure Nginx
echo -ne "       Configuring Nginx              [..]\r"
./configure $NGINX_OPTIONS $NGINX_MODULES &>/dev/null

if [ $? -eq 0 ]; then
	echo -ne "       Configuring Nginx              [${CGREEN}OK${CEND}]\r"
	echo -ne "\n"
else
	echo -e "       Configuring Nginx              [${CRED}FAIL${CEND}]"
	exit 1
fi

# Then we compile
echo -ne "       Compiling Nginx                [..]\r"
make -j $(nproc) &>/dev/null

if [ $? -eq 0 ]; then
	echo -ne "       Compiling Nginx                [${CGREEN}OK${CEND}]\r"
	echo -ne "\n"
else
	echo -e "       Compiling Nginx                [${CRED}FAIL${CEND}]"
	exit 1
fi

# Then we install \o/
echo -ne "       Installing Nginx               [..]\r"
make install &>/dev/null

if [ $? -eq 0 ]; then
	echo -ne "       Installing Nginx               [${CGREEN}OK${CEND}]\r"
	echo -ne "\n"
else
	echo -e "       Installing Nginx               [${CRED}FAIL${CEND}]"
	exit 1
fi

# Nginx installation from source does not add an init script for systemd.
# Using the official systemd script from nginx.org
if [[ ! -e /lib/systemd/system/nginx.service ]]; then
        cd /lib/systemd/system/
        wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.service &>/dev/null
        # Enable nginx start at boot
        systemctl enable nginx &>/dev/null
fi

# Nginx's cache directory is not created by default
if [[ ! -d /var/cache/nginx ]]; then
        mkdir -p /var/cache/nginx
fi

# Restart Nginx
echo -ne "       Restarting Nginx               [..]\r"
systemctl restart nginx &>/dev/null

if [ $? -eq 0 ]; then
	echo -ne "       Restarting Nginx               [${CGREEN}OK${CEND}]\r"
	echo -ne "\n"
else
	echo -e "       Restarting Nginx               [${CRED}FAIL${CEND}]"
	exit 1
fi

# We're done !
echo ""
echo -e "       ${CGREEN}Installation succcessful !${CEND}"
echo ""
