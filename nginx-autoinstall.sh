#!/bin/bash

if [[ "$EUID" -ne 0 ]]; then
	echo -e "Sorry, you need to run this as root"
	exit 1
fi

# Define versions
NGINX_MAINLINE_VER=1.17.10
NGINX_STABLE_VER=1.18.0
LIBRESSL_VER=3.0.2
OPENSSL_VER=1.1.1g
NPS_VER=1.13.35.2
HEADERMOD_VER=0.33
LIBMAXMINDDB_VER=1.3.2
GEOIP2_VER=3.3
LUA_JIT_VER=2.1-20181029
LUA_NGINX_VER=0.10.16rc5
NGINX_DEV_KIT=0.3.1

# Define installation paramaters for headless install (fallback if unspecifed)
if [[ "$HEADLESS" == "y" ]]; then
	OPTION=${OPTION:-1}
	NGINX_VER=${NGINX_VER:-1}
	PAGESPEED=${PAGESPEED:-n}
	BROTLI=${BROTLI:-n}
	HEADERMOD=${HEADERMOD:-n}
	GEOIP=${GEOIP:-n}
	FANCYINDEX=${FANCYINDEX:-n}
	CACHEPURGE=${CACHEPURGE:-n}
	LUA=${LUA:-n}
	WEBDAV=${WEBDAV:-n}
	VTS=${VTS:-n}
	TESTCOOKIE=${TESTCOOKIE:-n}
	HTTP3=${HTTP3:-n}
	MODSEC=${MODSEC:-n}
	SSL=${SSL:-1}
	RM_CONF=${RM_CONF:-y}
	RM_LOGS=${RM_LOGS:-y}
fi

# Clean screen before launching menu
if [[ "$HEADLESS" == "n" ]]; then
	clear
fi

if [[ "$HEADLESS" != "y" ]]; then
	echo ""
	echo "Welcome to the nginx-autoinstall script."
	echo ""
	echo "What do you want to do?"
	echo "   1) Install or update Nginx"
	echo "   2) Uninstall Nginx"
	echo "   3) Update the script"
	echo "   4) Install Bad Bot Blocker"
	echo "   5) Exit"
	echo ""
	while [[ $OPTION !=  "1" && $OPTION != "2" && $OPTION != "3" && $OPTION != "4" && $OPTION != "5" ]]; do
		read -p "Select an option [1-5]: " OPTION
	done
fi

case $OPTION in
	1)
		if [[ "$HEADLESS" != "y" ]]; then
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
		fi
		case $NGINX_VER in
			1)
			NGINX_VER=$NGINX_STABLE_VER
			;;
			2)
			NGINX_VER=$NGINX_MAINLINE_VER
			;;
			*)
			echo "NGINX_VER unspecified, fallback to stable $NGINX_STABLE_VER"
			NGINX_VER=$NGINX_STABLE_VER
			;;
		esac
		if [[ "$HEADLESS" != "y" ]]; then
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
			while [[ $FANCYINDEX != "y" && $FANCYINDEX != "n" ]]; do
				read -p "       Fancy index [y/n]: " -e FANCYINDEX
			done
			while [[ $CACHEPURGE != "y" && $CACHEPURGE != "n" ]]; do
				read -p "       ngx_cache_purge [y/n]: " -e CACHEPURGE
			done
			while [[ $LUA != "y" && $LUA != "n" ]]; do
				read -p "       ngx_http_lua_module [y/n]: " -e LUA
			done
			while [[ $WEBDAV != "y" && $WEBDAV != "n" ]]; do
				read -p "       nginx WebDAV [y/n]: " -e WEBDAV
			done
			while [[ $VTS != "y" && $VTS != "n" ]]; do
				read -p "       nginx VTS [y/n]: " -e VTS
			done
			while [[ $TESTCOOKIE != "y" && $TESTCOOKIE != "n" ]]; do
				read -p "       nginx testcookie [y/n]: " -e TESTCOOKIE
			done
			while [[ $HTTP3 != "y" && $HTTP3 != "n" ]]; do
				read -p "       HTTP/3 (by Cloudflare, WILL INSTALL BoringSSL, Quiche, Rust and Go) [y/n]: " -e HTTP3
			done
			while [[ $MODSEC != "y" && $MODSEC != "n" ]]; do
				read -p "       nginx ModSecurity [y/n]: " -e MODSEC
			done
			if [[ "$MODSEC" = 'y' ]]; then
				read -p "       Enable nginx ModSecurity? [y/n]: " -e MODSEC_ENABLE
			fi
			if [[ $NGINX_VER == $NGINX_MAINLINE_VER ]]; then
				# The patch only works on mainline
				while [[ $TLSDYN !=  "y" && $TLSDYN != "n" ]]; do
					read -p "       Cloudflare's TLS Dynamic Record Resizing patch [y/n]: " -e TLSDYN
				done
			fi
			if [[ "$HTTP3" != 'y' ]]; then
				echo ""
				echo "Choose your OpenSSL implementation:"
				echo "   1) System's OpenSSL ($(openssl version | cut -c9-14))"
				echo "   2) OpenSSL $OPENSSL_VER from source"
				echo "   3) LibreSSL $LIBRESSL_VER from source "
				echo ""
				while [[ $SSL != "1" && $SSL != "2" && $SSL != "3" ]]; do
					read -p "Select an option [1-3]: " SSL
				done
			fi
		fi
		if [[ "$HTTP3" != 'y' ]]; then
			case $SSL in
				1)
				;;
				2)
					OPENSSL=y
				;;
				3)
					LIBRESSL=y
				;;
				*)
					echo "SSL unspecified, fallback to system's OpenSSL ($(openssl version | cut -c9-14))"
				;;
			esac
		fi
		if [[ "$HEADLESS" != "y" ]]; then
			echo ""
			read -n1 -r -p "Nginx is ready to be installed, press any key to continue..."
			echo ""
		fi

		# Cleanup
		# The directory should be deleted at the end of the script, but in case it fails
		rm -r /usr/local/src/nginx/ >> /dev/null 2>&1
		mkdir -p /usr/local/src/nginx/modules

		# Dependencies
		apt-get update
		apt-get install -y build-essential ca-certificates wget curl libpcre3 libpcre3-dev autoconf unzip automake libtool tar git libssl-dev zlib1g-dev uuid-dev lsb-release libxml2-dev libxslt1-dev cmake

		if [[ "$MODSEC" = 'y' ]]; then
				apt-get install -y apt-utils libcurl4-openssl-dev libgeoip-dev liblmdb-dev libpcre++-dev libyajl-dev pkgconf
		fi

		# PageSpeed
		if [[ "$PAGESPEED" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			wget https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VER}-stable.zip
			unzip v${NPS_VER}-stable.zip
			cd incubator-pagespeed-ngx-${NPS_VER}-stable || exit 1
			psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_VER}.tar.gz
			[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
			wget "${psol_url}"
			tar -xzvf "$(basename "${psol_url}")"
		fi

		#Brotli
		if [[ "$BROTLI" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			git clone https://github.com/google/ngx_brotli
			cd ngx_brotli || exit 1
			git submodule update --init
		fi

		# More Headers
		if [[ "$HEADERMOD" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERMOD_VER}.tar.gz
			tar xaf v${HEADERMOD_VER}.tar.gz
		fi

		# GeoIP
		if [[ "$GEOIP" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			# install libmaxminddb
			wget https://github.com/maxmind/libmaxminddb/releases/download/${LIBMAXMINDDB_VER}/libmaxminddb-${LIBMAXMINDDB_VER}.tar.gz
			tar xaf libmaxminddb-${LIBMAXMINDDB_VER}.tar.gz
			cd libmaxminddb-${LIBMAXMINDDB_VER}/
			./configure
			make -j "$(nproc)"
			make install
			ldconfig

			cd ../
			wget https://github.com/leev/ngx_http_geoip2_module/archive/${GEOIP2_VER}.tar.gz
			tar xaf ${GEOIP2_VER}.tar.gz

			mkdir geoip-db
			cd geoip-db || exit 1
			wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz
			wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz
			tar -xf GeoLite2-City.tar.gz
			tar -xf GeoLite2-Country.tar.gz
			mkdir /opt/geoip
			cd GeoLite2-City_*/
			mv GeoLite2-City.mmdb /opt/geoip/
			cd ../
			cd GeoLite2-Country_*/
			mv GeoLite2-Country.mmdb /opt/geoip/
		fi

		# Cache Purge
		if [[ "$CACHEPURGE" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			git clone https://github.com/FRiCKLE/ngx_cache_purge
		fi

		# Lua
		if [[ "$LUA" = 'y' ]]; then
			# LuaJIT download
			cd /usr/local/src/nginx/modules
			wget https://github.com/openresty/luajit2/archive/v${LUA_JIT_VER}.tar.gz
			tar xaf v${LUA_JIT_VER}.tar.gz
			cd luajit2-${LUA_JIT_VER}
			make -j "$(nproc)"
			make install

			# ngx_devel_kit download
			cd /usr/local/src/nginx/modules
			wget https://github.com/simplresty/ngx_devel_kit/archive/v${NGINX_DEV_KIT}.tar.gz
			tar xaf v${NGINX_DEV_KIT}.tar.gz

			# lua-nginx-module download
			cd /usr/local/src/nginx/modules
			wget https://github.com/openresty/lua-nginx-module/archive/v${LUA_NGINX_VER}.tar.gz
			tar xaf v${LUA_NGINX_VER}.tar.gz

		fi

		# LibreSSL
		if [[ "$LIBRESSL" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			mkdir libressl-${LIBRESSL_VER}
			cd libressl-${LIBRESSL_VER} || exit 1
			wget -qO- http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VER}.tar.gz | tar xz --strip 1

			./configure \
				LDFLAGS=-lrt \
				CFLAGS=-fstack-protector-strong \
				--prefix=/usr/local/src/nginx/modules/libressl-${LIBRESSL_VER}/.openssl/ \
				--enable-shared=no

			make install-strip -j "$(nproc)"
		fi

		# OpenSSL
		if [[ "$OPENSSL" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			wget https://www.openssl.org/source/openssl-${OPENSSL_VER}.tar.gz
			tar xaf openssl-${OPENSSL_VER}.tar.gz
			cd openssl-${OPENSSL_VER}

			./config
		fi

		# ModSecurity
		if [[ "$MODSEC" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity
			cd ModSecurity
			git submodule init
			git submodule update
			./build.sh
			./configure
			make -j "$(nproc)"
			make install
			mkdir /etc/nginx/modsec
			wget -P /etc/nginx/modsec/ https://raw.githubusercontent.com/SpiderLabs/ModSecurity/v3/master/modsecurity.conf-recommended
			mv /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf

			# Enable ModSecurity in Nginx
			if [[ "$MODSEC_ENABLE" = 'y' ]]; then
				sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
			fi
		fi

		# Download and extract of Nginx source code
		cd /usr/local/src/nginx/ || exit 1
		wget -qO- http://nginx.org/download/nginx-${NGINX_VER}.tar.gz | tar zxf -
		cd nginx-${NGINX_VER}

		# As the default nginx.conf does not work, we download a clean and working conf from my GitHub.
		# We do it only if it does not already exist, so that it is not overriten if Nginx is being updated
		if [[ ! -e /etc/nginx/nginx.conf ]]; then
			mkdir -p /etc/nginx
			cd /etc/nginx || exit 1
			wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.conf
		fi
		cd /usr/local/src/nginx/nginx-${NGINX_VER} || exit 1

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
		--with-cc-opt=-Wno-deprecated-declarations \
		--with-cc-opt=-Wno-ignored-qualifiers"

		NGINX_MODULES="--with-threads \
		--with-file-aio \
		--with-http_ssl_module \
		--with-http_v2_module \
		--with-http_mp4_module \
		--with-http_auth_request_module \
		--with-http_slice_module \
		--with-http_stub_status_module \
		--with-http_realip_module \
		--with-http_sub_module"

		# Optional options
		if [[ "$LUA" = 'y' ]]; then
			NGINX_OPTIONS=$(echo $NGINX_OPTIONS; echo --with-ld-opt="-Wl,-rpath,/usr/local/lib/")
		fi

		# Optional modules
		if [[ "$LIBRESSL" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --with-openssl=/usr/local/src/nginx/modules/libressl-${LIBRESSL_VER})
		fi

		if [[ "$PAGESPEED" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo "--add-module=/usr/local/src/nginx/modules/incubator-pagespeed-ngx-${NPS_VER}-stable")
		fi

		if [[ "$BROTLI" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo "--add-module=/usr/local/src/nginx/modules/ngx_brotli")
		fi

		if [[ "$HEADERMOD" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo "--add-module=/usr/local/src/nginx/modules/headers-more-nginx-module-${HEADERMOD_VER}")
		fi

		if [[ "$GEOIP" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo "--add-module=/usr/local/src/nginx/modules/ngx_http_geoip2_module-${GEOIP2_VER}")
		fi

		if [[ "$OPENSSL" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo "--with-openssl=/usr/local/src/nginx/modules/openssl-${OPENSSL_VER}")
		fi

		if [[ "$CACHEPURGE" = 'y' ]]; then
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo "--add-module=/usr/local/src/nginx/modules/ngx_cache_purge")
		fi

		# Lua
		if [[ "$LUA" = 'y' ]]; then
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/usr/local/src/nginx/modules/ngx_devel_kit-${NGINX_DEV_KIT}")
			NGINX_MODULES=$(echo $NGINX_MODULES; echo "--add-module=/usr/local/src/nginx/modules/lua-nginx-module-${LUA_NGINX_VER}")
		fi

		if [[ "$FANCYINDEX" = 'y' ]]; then
			git clone --quiet https://github.com/aperezdc/ngx-fancyindex.git /usr/local/src/nginx/modules/fancyindex
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --add-module=/usr/local/src/nginx/modules/fancyindex)
		fi

		if [[ "$WEBDAV" = 'y' ]]; then
			git clone --quiet https://github.com/arut/nginx-dav-ext-module.git /usr/local/src/nginx/modules/nginx-dav-ext-module
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --with-http_dav_module --add-module=/usr/local/src/nginx/modules/nginx-dav-ext-module)
		fi

		if [[ "$VTS" = 'y' ]]; then
			git clone --quiet https://github.com/vozlt/nginx-module-vts.git /usr/local/src/nginx/modules/nginx-module-vts
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --add-module=/usr/local/src/nginx/modules/nginx-module-vts)
		fi

		if [[ "$TESTCOOKIE" = 'y' ]]; then
			git clone --quiet https://github.com/kyprizel/testcookie-nginx-module.git /usr/local/src/nginx/modules/testcookie-nginx-module
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --add-module=/usr/local/src/nginx/modules/testcookie-nginx-module)
		fi

		if [[ "$MODSEC" = 'y' ]]; then
			git clone --quiet https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/nginx/modules/ModSecurity-nginx
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --add-module=/usr/local/src/nginx/modules/ModSecurity-nginx)
		fi

		# Cloudflare's TLS Dynamic Record Resizing patch
		if [[ "$TLSDYN" = 'y' ]]; then
			wget https://raw.githubusercontent.com/nginx-modules/ngx_http_tls_dyn_size/master/nginx__dynamic_tls_records_1.17.7%2B.patch -O tcp-tls.patch
			patch -p1 < tcp-tls.patch
		fi

		# HTTP3
		if [[ "$HTTP3" = 'y' ]]; then
			cd /usr/local/src/nginx/modules || exit 1
			git clone --recursive https://github.com/cloudflare/quiche
			# Dependencies for BoringSSL and Quiche
			apt-get install -y golang
			# Rust is not packaged so that's the only way...
			curl -sSf https://sh.rustup.rs | sh -s -- -y
			source $HOME/.cargo/env

			cd /usr/local/src/nginx/nginx-${NGINX_VER} || exit 1
			# Apply actual patch
			patch -p01 < /usr/local/src/nginx/modules/quiche/extras/nginx/nginx-1.16.patch

			NGINX_OPTIONS=$(echo "$NGINX_OPTIONS"; echo --with-openssl=/usr/local/src/nginx/modules/quiche/deps/boringssl --with-quiche=/usr/local/src/nginx/modules/quiche)
			NGINX_MODULES=$(echo "$NGINX_MODULES"; echo --with-http_v3_module)
		fi

		if [[ "$LUA" = 'y' ]]; then
			export LUAJIT_LIB=/usr/local/lib/
 			export LUAJIT_INC=/usr/local/include/luajit-2.1/
		fi

		./configure $NGINX_OPTIONS $NGINX_MODULES
		make -j "$(nproc)"
		make install

		# remove debugging symbols
		strip -s /usr/sbin/nginx

		# Nginx installation from source does not add an init script for systemd and logrotate
		# Using the official systemd script and logrotate conf from nginx.org
		if [[ ! -e /lib/systemd/system/nginx.service ]]; then
			cd /lib/systemd/system/ || exit 1
			wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx.service
			# Enable nginx start at boot
			systemctl enable nginx
		fi

		if [[ ! -e /etc/logrotate.d/nginx ]]; then
			cd /etc/logrotate.d/ || exit 1
			wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/conf/nginx-logrotate -O nginx
		fi

		# Nginx's cache directory is not created by default
		if [[ ! -d /var/cache/nginx ]]; then
			mkdir -p /var/cache/nginx
		fi

		# We add the sites-* folders as some use them.
		if [[ ! -d /etc/nginx/sites-available ]]; then
			mkdir -p /etc/nginx/sites-available
		fi
		if [[ ! -d /etc/nginx/sites-enabled ]]; then
			mkdir -p /etc/nginx/sites-enabled
		fi
		if [[ ! -d /etc/nginx/conf.d ]]; then
			mkdir -p /etc/nginx/conf.d
		fi

		# Restart Nginx
		systemctl restart nginx

		# Block Nginx from being installed via APT
		if [[ $(lsb_release -si) == "Debian" ]] || [[ $(lsb_release -si) == "Ubuntu" ]]
		then
			cd /etc/apt/preferences.d/ || exit 1
			echo -e "Package: nginx*\\nPin: release *\\nPin-Priority: -1" > nginx-block
		fi

		# Removing temporary Nginx and modules files
		rm -r /usr/local/src/nginx

		# We're done !
		echo "Installation done."
	exit
	;;
	2) # Uninstall Nginx
		if [[ "$HEADLESS" != "y" ]]; then
			while [[ $RM_CONF !=  "y" && $RM_CONF != "n" ]]; do
				read -p "       Remove configuration files ? [y/n]: " -e RM_CONF
			done
			while [[ $RM_LOGS !=  "y" && $RM_LOGS != "n" ]]; do
				read -p "       Remove logs files ? [y/n]: " -e RM_LOGS
			done
		fi
		# Stop Nginx
		systemctl stop nginx

		# Removing Nginx files and modules files
		rm -r /usr/local/src/nginx \
		/usr/sbin/nginx* \
		/usr/local/bin/luajit* \
		/usr/local/include/luajit* \
		/etc/logrotate.d/nginx \
		/var/cache/nginx \
		/lib/systemd/system/nginx.service \
		/etc/systemd/system/multi-user.target.wants/nginx.service

		# Remove conf files
		if [[ "$RM_CONF" = 'y' ]]; then
			rm -r /etc/nginx/
		fi

		# Remove logs
		if [[ "$RM_LOGS" = 'y' ]]; then
			rm -r /var/log/nginx
		fi

		# Remove Nginx APT block
		if [[ $(lsb_release -si) == "Debian" ]] || [[ $(lsb_release -si) == "Ubuntu" ]]
		then
			rm /etc/apt/preferences.d/nginx-block
		fi

		# We're done !
		echo "Uninstallation done."

		exit
	;;
	3) # Update the script
		wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/nginx-autoinstall.sh -O nginx-autoinstall.sh
		chmod +x nginx-autoinstall.sh
		echo ""
		echo "Update done."
		sleep 2
		./nginx-autoinstall.sh
		exit
	;;
	4) # Install Bad Bot Blocker
		echo ""
		echo "This will install Nginx Bad Bot and User-Agent Blocker."
		echo ""
		echo "First step is to download the install script."
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		wget https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/install-ngxblocker -O /usr/local/sbin/install-ngxblocker
		chmod +x /usr/local/sbin/install-ngxblocker

		echo ""
		echo "Install script has been downloaded."
		echo ""
		echo "Second step is to run the install-ngxblocker script in DRY-MODE,"
		echo "which will show you what changes it will make and what files it will download for you.."
		echo "This is only a DRY-RUN so no changes are being made yet."
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		cd /usr/local/sbin || exit 1
		./install-ngxblocker

		echo ""
		echo "Third step is to run the install script with the -x parameter,"
		echo "to download all the necessary files from the repository.."
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		cd /usr/local/sbin/ || exit 1
		./install-ngxblocker -x
		chmod +x /usr/local/sbin/setup-ngxblocker
		chmod +x /usr/local/sbin/update-ngxblocker

		echo ""
		echo "All the required files have now been downloaded to the correct folders,"
		echo " on Nginx for you directly from the repository."
		echo ""
		echo "Fourth step is to run the setup-ngxblocker script in DRY-MODE,"
		echo "which will show you what changes it will make and what files it will download for you."
		echo "This is only a DRY-RUN so no changes are being made yet."
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		cd /usr/local/sbin/ || exit 1
		./setup-ngxblocker -e conf

		echo ""
		echo "Fifth step is to run the setup script with the -x parameter,"
		echo "to make all the necessary changes to your nginx.conf (if required),"
		echo "and also to add the required includes into all your vhost files."
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		cd /usr/local/sbin/ || exit 1
		./setup-ngxblocker -x -e conf

		echo ""
		echo "Sixth step is to test your nginx configuration"
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		/usr/sbin/nginx -t

		echo ""
		echo "Seventh step is to restart Nginx,"
		echo "and the Bot Blocker will immediately be active and protecting all your web sites."
		echo ""
		read -n1 -r -p " press any key to continue..."
		echo ""

		/usr/sbin/nginx -t && systemctl restart nginx

		echo "That's it, the blocker is now active and protecting your sites from thousands of malicious bots and domains."
		echo ""
		echo "For more info, visit: https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker"
		echo ""
		sleep 2
		exit
	;;
	*) # Exit
		exit
	;;

esac
