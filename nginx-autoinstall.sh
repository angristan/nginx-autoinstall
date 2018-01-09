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

# Variables
NGINX_MAINLINE_VER=1.13.8
NGINX_STABLE_VER=1.12.2
LIBRESSL_VER=2.6.4
OPENSSL_VER=1.1.0g
NPS_VER=1.12.34.3
HEADERMOD_VER=0.33

# Clear log files
echo "" > /tmp/nginx-autoinstall-output.log
echo "" > /tmp/nginx-autoinstall-error.log

clear
echo ""
echo "Welcome to the nginx-autoinstall script."
echo ""
echo "What do you want to do?"
echo "   1) Install or update Nginx"
echo "   2) Uninstall Nginx"
echo "   3) Update the script"
echo "   4) Exit"
echo ""
while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" ]]; do
	read -p "Select an option [1-4]: " OPTION
done
case $OPTION in
	1)
		echo ""
		echo "This script will install Nginx with some optional modules."
		echo ""
		echo "Do you want to install Nginx stable or mainline?"
		echo "   1) Stable $NGINX_STABLE_VER"
		echo "   2) Mainline $NGINX_MAINLINE_VER"
		echo ""
		while [[ $NGINX_VER != "1" && $NGINX_VER != "2" ]]; do
			read -p "Select an option [1-2]: " NGINX_VER
		done
		case $NGINX_VER in
			1)
			NGINX_VER=$NGINX_STABLE_VER
			;;
			2)
			NGINX_VER=$NGINX_MAINLINE_VER
			;;
		esac
		echo ""
		echo "Please tell me which modules you want to install."
		echo "If you select none, Nginx will be installed with its default modules."
		echo ""
		echo "Modules to install :"
		while [[ $PAGESPEED != "y" && $PAGESPEED != "n" ]]; do
			read -p "       PageSpeed $NPS_VER [y/n]: " -e PAGESPEED
		done
		while [[ $BROTLI != "y" && $BROTLI != "n" ]]; do
			read -p "       Brotli [y/n]: " -e BROTLI
		done
		while [[ $HEADERMOD != "y" && $HEADERMOD != "n" ]]; do
			read -p "       Headers More $HEADERMOD_VER [y/n]: " -e HEADERMOD
		done
		while [[ $GEOIP != "y" && $GEOIP != "n" ]]; do
			read -p "       GeoIP [y/n]: " -e GEOIP
		done
		while [[ $TCP != "y" && $TCP != "n" ]]; do
			read -p "       Cloudflare's TLS Dynamic Record Resizing patch [y/n]: " -e TCP
		done
		echo ""
		echo "Choose your OpenSSL implementation :"
		echo "   1) System's OpenSSL ($(openssl version | cut -c9-14))"
		echo "   2) OpenSSL $OPENSSL_VER from source"
		echo "   3) LibreSSL $LIBRESSL_VER from source "
		echo ""
		while [[ $SSL != "1" && $SSL != "2" && $SSL != "3" ]]; do
			read -p "Select an option [1-3]: " SSL
		done
		case $SSL in
			1)
			#we do nothing
			;;
			2)
				OPENSSL=y
			;;
			3)
				LIBRESSL=y
			;;
		esac
		echo ""
		read -n1 -r -p "Nginx is ready to be installed, press any key to continue..."
		echo ""

		# Cleanup
		# The directory should be deleted at the end of the script, but in case it fails
		rm -r /usr/local/src/nginx/ 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		mkdir -p /usr/local/src/nginx/modules 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

		# Dependencies
		echo -ne "       Installing dependencies      [..]\r"
		apt-get update 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		apt-get install build-essential ca-certificates wget curl libpcre3 libpcre3-dev autoconf unzip automake libtool tar git libssl-dev zlib1g-dev -y 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

		if [ $? -eq 0 ]; then
			echo -ne "       Installing dependencies        [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "        Installing dependencies      [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi

		# PageSpeed
		if [[ "$PAGESPEED" = 'y' ]]; then
			cd /usr/local/src/nginx/modules
			# Download and extract of PageSpeed module
			echo -ne "       Downloading ngx_pagespeed      [..]\r"
			wget https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VER}-stable.zip 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			unzip v${NPS_VER}-stable.zip 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			cd incubator-pagespeed-ngx-${NPS_VER}-stable
			psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_VER}.tar.gz
			[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
			wget ${psol_url} 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			tar -xzvf $(basename ${psol_url}) 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
			echo -ne "       Downloading ngx_pagespeed      [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Downloading ngx_pagespeed      [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		#Brotli
		if [[ "$BROTLI" = 'y' ]]; then
			cd /usr/local/src/nginx/modules
			# libbrolti is needed for the ngx_brotli module
			# libbrotli download
			echo -ne "       Downloading libbrotli          [..]\r"
			git clone https://github.com/bagder/libbrotli 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Downloading libbrotli          [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Downloading libbrotli          [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			cd libbrotli
			echo -ne "       Configuring libbrotli          [..]\r"
			./autogen.sh 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			./configure 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Configuring libbrotli          [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Configuring libbrotli          [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			echo -ne "       Compiling libbrotli            [..]\r"
			make -j $(nproc) 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Compiling libbrotli            [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Compiling libbrotli            [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			# libbrotli install
			echo -ne "       Installing libbrotli           [..]\r"
			make install 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Installing libbrotli           [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Installing libbrotli           [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			# Linking libraries to avoid errors
			ldconfig 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			# ngx_brotli module download
			cd /usr/local/src/nginx/modules
			echo -ne "       Downloading ngx_brotli         [..]\r"
			git clone https://github.com/google/ngx_brotli 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			cd ngx_brotli
			git submodule update --init 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Downloading ngx_brotli         [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Downloading ngx_brotli         [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		# More Headers
		if [[ "$HEADERMOD" = 'y' ]]; then
			cd /usr/local/src/nginx/modules
			echo -ne "       Downloading ngx_headers_more   [..]\r"
			wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERMOD_VER}.tar.gz 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			tar xaf v${HEADERMOD_VER}.tar.gz
				
			if [ $? -eq 0 ]; then
				echo -ne "       Downloading ngx_headers_more   [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Downloading ngx_headers_more   [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		# GeoIP
		if [[ "$GEOIP" = 'y' ]]; then
			# Dependence
			apt-get install libgeoip-dev -y 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			cd /usr/local/src/nginx/modules
			mkdir geoip-db
			cd geoip-db
			echo -ne "       Downloading GeoIP databases    [..]\r"
			wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			gunzip GeoIP.dat.gz
			gunzip GeoLiteCity.dat.gz
			mv GeoIP.dat GeoIP-Country.dat
			mv GeoLiteCity.dat GeoIP-City.dat

			if [ $? -eq 0 ]; then
				echo -ne "       Downloading GeoIP databases    [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Downloading GeoIP databases    [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		# LibreSSL
		if [[ "$LIBRESSL" = 'y' ]]; then
			cd /usr/local/src/nginx/modules
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
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			echo -ne "       Configuring LibreSSL           [..]\r"
			./configure \
				LDFLAGS=-lrt \
				CFLAGS=-fstack-protector-strong \
				--prefix=/usr/local/src/nginx/modules/libressl-${LIBRESSL_VER}/.openssl/ \
				--enable-shared=no 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Configuring LibreSSL           [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Configuring LibreSSL         [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			# LibreSSL install
			echo -ne "       Installing LibreSSL            [..]\r"
			make install-strip -j $(nproc) 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

			if [ $? -eq 0 ]; then
				echo -ne "       Installing LibreSSL            [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Installing LibreSSL            [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		# OpenSSL
		if [[ "$OPENSSL" = 'y' ]]; then
			cd /usr/local/src/nginx/modules
			# OpenSSL download
			echo -ne "       Downloading OpenSSL            [..]\r"
			wget https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log 
			tar xaf openssl-${OPENSSL_VER}.tar.gz
			cd openssl-${OPENSSL_VER}	
			if [ $? -eq 0 ]; then
				echo -ne "       Downloading OpenSSL            [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Downloading OpenSSL            [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi

			echo -ne "       Configuring OpenSSL            [..]\r"
			./config 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log 

			if [ $? -eq 0 ]; then
				echo -ne "       Configuring OpenSSL            [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       Configuring OpenSSL          [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		# Download and extract of Nginx source code
		cd /usr/local/src/nginx/
		echo -ne "       Downloading Nginx              [..]\r"
		wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxf -
		cd nginx-${NGINX_VER}

		if [ $? -eq 0 ]; then
			echo -ne "       Downloading Nginx              [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Downloading Nginx              [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi

		# As the default nginx.conf does not work
		# We download a clean and working conf from my GitHub.
		# We do it only if it does not already exist (in case of update for instance)
		if [[ ! -e /etc/nginx/nginx.conf ]]; then
			mkdir -p /etc/nginx
			cd /etc/nginx
			wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.conf 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		fi
		cd /usr/local/src/nginx/nginx-${NGINX_VER}

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
		--group=nginx \
		--with-cc-opt=-Wno-deprecated-declarations"


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
		--with-http_mp4_module \
		--with-http_auth_request_module \
		--with-http_slice_module \
		--with-http_stub_status_module \
		--with-http_realip_module"

		# Optional modules
		# LibreSSL 
		if [[ "$LIBRESSL" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo --with-openssl=/usr/local/src/nginx/modules/libressl-${LIBRESSL_VER})
		fi

		# PageSpeed
		if [[ "$PAGESPEED" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/usr/local/src/nginx/modules/incubator-pagespeed-ngx-${NPS_VER}-stable")
		fi

		# Brotli
		if [[ "$BROTLI" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/usr/local/src/nginx/modules/ngx_brotli")
		fi

		# More Headers
		if [[ "$HEADERMOD" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/usr/local/src/nginx/modules/headers-more-nginx-module-${HEADERMOD_VER}")
		fi

		# GeoIP
		if [[ "$GEOIP" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--with-http_geoip_module")
		fi

		# OpenSSL
		if [[ "$OPENSSL" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--with-openssl=/usr/local/src/nginx/modules/openssl-${OPENSSL_VER}")
		fi
	
		# Cloudflare's TLS Dynamic Record Resizing patch
		if [[ "$TCP" = 'y' ]]; then
			echo -ne "       TLS Dynamic Records support    [..]\r"
			wget https://raw.githubusercontent.com/cloudflare/sslconfig/master/patches/nginx__1.11.5_dynamic_tls_records.patch 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			patch -p1 < nginx__1.11.5_dynamic_tls_records.patch 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		        
			if [ $? -eq 0 ]; then
				echo -ne "       TLS Dynamic Records support    [${CGREEN}OK${CEND}]\r"
				echo -ne "\n"
			else
				echo -e "       TLS Dynamic Records support    [${CRED}FAIL${CEND}]"
				echo ""
				echo "Please look /tmp/nginx-autoinstall-error.log"
				echo ""
				exit 1
			fi
		fi

		# We configure Nginx
		echo -ne "       Configuring Nginx              [..]\r"
		./configure $NGINX_OPTIONS $NGINX_MODULES 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

		if [ $? -eq 0 ]; then
			echo -ne "       Configuring Nginx              [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Configuring Nginx              [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi

		# Then we compile
		echo -ne "       Compiling Nginx                [..]\r"
		make -j $(nproc) 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

		if [ $? -eq 0 ]; then
			echo -ne "       Compiling Nginx                [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Compiling Nginx                [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi

		# Then we install \o/
		echo -ne "       Installing Nginx               [..]\r"
		make install 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		
		# remove debugging symbols
		strip -s /usr/sbin/nginx

		if [ $? -eq 0 ]; then
			echo -ne "       Installing Nginx               [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Installing Nginx               [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi

		# Nginx installation from source does not add an init script for systemd and logrotate
		# Using the official systemd script and logrotate conf from nginx.org
		if [[ ! -e /lib/systemd/system/nginx.service ]]; then
			cd /lib/systemd/system/
			wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.service 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			# Enable nginx start at boot
			systemctl enable nginx 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		fi

		if [[ ! -e /etc/logrotate.d/nginx ]]; then
			cd /etc/logrotate.d/
			wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx-logrotate -O nginx 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		fi

		# Nginx's cache directory is not created by default
		if [[ ! -d /var/cache/nginx ]]; then
			mkdir -p /var/cache/nginx
		fi

		# We add sites-* folders as some use them. /etc/nginx/conf.d/ is the vhost folder by defaultnginx 
		if [[ ! -d /etc/nginx/sites-available ]]; then
			mkdir -p /etc/nginx/sites-available
		fi
		if [[ ! -d /etc/nginx/sites-enabled ]]; then
			mkdir -p /etc/nginx/sites-enabled
		fi

		# Restart Nginx
		echo -ne "       Restarting Nginx               [..]\r"
		systemctl restart nginx 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

		if [ $? -eq 0 ]; then
			echo -ne "       Restarting Nginx               [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Restarting Nginx               [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi

		# Removing temporary Nginx and modules files
		echo -ne "       Removing Nginx files           [..]\r"
		rm -r /usr/local/src/nginx 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		echo -ne "       Removing Nginx files           [${CGREEN}OK${CEND}]\r"
		echo -ne "\n"

		# We're done !
		echo ""
		echo -e "       ${CGREEN}Installation successful !${CEND}"
		echo ""
	exit
	;;
	2) # Uninstall Nginx
		while [[ $CONF !=  "y" && $CONF != "n" ]]; do
			read -p "       Remove configuration files ? [y/n]: " -e CONF
		done
		while [[ $LOGS !=  "y" && $LOGS != "n" ]]; do
			read -p "       Remove logs files ? [y/n]: " -e LOGS
		done
		# Stop Nginx
		echo -ne "       Stopping Nginx                 [..]\r"
		systemctl stop nginx
		if [ $? -eq 0 ]; then
			echo -ne "       Stopping Nginx                 [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		else
			echo -e "       Stopping Nginx                 [${CRED}FAIL${CEND}]"
			echo ""
			echo "Please look /tmp/nginx-autoinstall-error.log"
			echo ""
			exit 1
		fi
		# Removing Nginx files and modules files
		echo -ne "       Removing Nginx files           [..]\r"
		rm -r /usr/local/src/nginx
		/usr/sbin/nginx* \
		/etc/logrotate.d/nginx \
		/var/cache/nginx \
		/lib/systemd/system/nginx.service \
		/etc/systemd/system/multi-user.target.wants/nginx.service 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log

		echo -ne "       Removing Nginx files           [${CGREEN}OK${CEND}]\r"
		echo -ne "\n"

		# Remove conf files
		if [[ "$CONF" = 'y' ]]; then
			echo -ne "       Removing configuration files   [..]\r"
			rm -r /etc/nginx/ 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			echo -ne "       Removing configuration files   [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		fi

		# Remove logs
		if [[ "$LOGS" = 'y' ]]; then
			echo -ne "       Removing log files             [..]\r"
			rm -r /var/log/nginx 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
			echo -ne "       Removing log files             [${CGREEN}OK${CEND}]\r"
			echo -ne "\n"
		fi

		#We're done !
		echo ""
		echo -e "       ${CGREEN}Uninstallation successful !${CEND}"
		echo ""

	exit
	;;
	3) # Update the script
		wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/nginx-autoinstall.sh -O nginx-autoinstall.sh 2>> /tmp/nginx-autoinstall-error.log 1>> /tmp/nginx-autoinstall-output.log
		chmod +x nginx-autoinstall.sh
		echo ""
		echo -e "${CGREEN}Update succcessful !${CEND}"
		sleep 2
		./nginx-autoinstall.sh
		exit
	;;
	4) # Exit
		exit
	;;

esac
