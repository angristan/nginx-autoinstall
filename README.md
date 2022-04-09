# nginx-autoinstall

Compile and install NGINX from source with optional features, modules and patches.

## Compatibility

- Debian 9 and later
- Ubuntu 16.04 and later

The script might work on ARM-based architectures, but it's only being regularly tested against x86_64 with [GitHub Actions](https://github.com/angristan/nginx-autoinstall/actions/workflows/build.yml).

## Features

- Latest mainline or stable version, from source
- Optional modules and patches
- [Custom nginx.conf](https://github.com/angristan/nginx-autoinstall/blob/master/conf/nginx.conf) (default does not work)
- [Init script for systemd](https://github.com/angristan/nginx-autoinstall/blob/master/conf/nginx.service) (not provided by default)
- [Logrotate conf](https://github.com/angristan/nginx-autoinstall/blob/master/conf/nginx-logrotate) (not provided by default)
- Block Nginx installation from APT using pinning, to prevent conflicts

### Optional modules/features

- [LibreSSL from source](http://www.libressl.org/) (CHACHA20, ALPN for HTTP/2, X25519, P-521)
- [OpenSSL from source](https://www.openssl.org/) (TLS 1.3, CHACHA20, ALPN for HTTP/2, X25519, P-521)
- [Cloudflare's patch for HTTP/3](https://blog.cloudflare.com/experiment-with-http-3-using-nginx-and-quiche/) with [Quiche](https://github.com/cloudflare/quiche) and [BoringSSL](https://github.com/google/boringssl).
- [Cloudflare's TLS Dynamic Record Resizing patch](https://blog.cloudflare.com/optimizing-tls-over-tcp-to-reduce-latency/) maintained by [nginx-modules](https://github.com/nginx-modules/ngx_http_tls_dyn_size).
- [Cloudflare's HTTP/2 HPACK encoding patch](https://blog.cloudflare.com/hpack-the-silent-killer-feature-of-http-2/) ([original patch](https://github.com/cloudflare/sslconfig/blob/master/patches/nginx_1.13.1_http2_hpack.patch), [fixed patch](https://github.com/hakasenyang/openssl-patch/blob/master/nginx_hpack_push_1.15.3.patch))
- [ngx_pagespeed](https://github.com/pagespeed/ngx_pagespeed): Google performance module
- [ngx_brotli](https://github.com/google/ngx_brotli): Brotli compression algorithm
- [ngx_headers_more](https://github.com/openresty/headers-more-nginx-module): Custom HTTP headers
- [ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module) with [libmaxminddb](https://github.com/maxmind/libmaxminddb) and [GeoLite2 databases](https://dev.maxmind.com/geoip/geoip2/geolite2/) ⚠️ Requires license key
- [ngx_cache_purge](https://github.com/FRiCKLE/ngx_cache_purge): Purge content from FastCGI, proxy, SCGI and uWSGI caches
- [ngx-fancyindex](https://github.com/aperezdc/ngx-fancyindex) : fancy file listings
- [nginx-dav-ext-module](https://github.com/arut/nginx-dav-ext-module): WebDAV PROPFIND, OPTIONS, LOCK, UNLOCK support)
- [nginx-module-vts](https://github.com/vozlt/nginx-module-vts): Nginx virtual host traffic status module ([install instructions](https://github.com/vozlt/nginx-module-vts#installation))
- [ModSecurity-nginx](https://github.com/SpiderLabs/ModSecurity-nginx): connector for the [ModSecurity](https://github.com/SpiderLabs/ModSecurity) open-source web application firewall (WAF)
- [testcookie-nginx-module](https://github.com/kyprizel/testcookie-nginx-module): simple robot mitigation module using cookie based challenge/response ([example config](https://github.com/kyprizel/testcookie-nginx-module#example-configuration))
- [lua-nginx-module](https://github.com/openresty/lua-nginx-module): extend NGINX with Lua. Using [luajit2](https://github.com/openresty/luajit2) (OpenResty's maintained branch of LuaJIT) and [ngx_devel_kit](https://github.com/simplresty/ngx_devel_kit) (Nginx Development Kit (NDK))
- [nginx_substitutions_filter](https://github.com/yaoweibin/ngx_http_substitutions_filter_module): regular expression and fixed string substitutions for nginx
- [RTMP module](https://github.com/arut/nginx-rtmp-module) (NGINX-based Media Streaming Server)
- [nginx-ultimate-bad-bot-blocker](https://github.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker): Bad Bot and User-Agent Blocker, Spam Referrer Blocker, Anti DDOS, Bad IP Blocker and Wordpress Theme Detector Blocker

#### Cache Modules

- [redis2-nginx-module](https://github.com/openresty/redis2-nginx-module) : Nginx upstream module for the Redis 2.0 protocol
- [ngx_http_redis](https://www.nginx.com/resources/wiki/modules/redis/) : The nginx HTTP redis module for caching with redis
- [srcache-nginx-module](https://github.com/openresty/srcache-nginx-module) : Transparent subrequest-based caching layout for arbitrary nginx locations
- [set-misc-nginx-module](https://github.com/openresty/set-misc-nginx-module) : Various set_xxx directives added to nginx's rewrite module (md5/sha1, sql/json quoting, and many more)
- [echo-nginx-module](https://github.com/openresty/echo-nginx-module) : Brings "echo", "sleep", "time", "exec" and more shell-style goodies to Nginx config file.
  - Required to set up [Redis with conditional purging](https://easyengine.io/wordpress-nginx/tutorials/single-site/redis_cache-with-conditional-purging/)
  - Install Redis with ```apt install redis-{tools,server}```

## Usage

Just download and execute the script :

```sh
wget https://raw.githubusercontent.com/angristan/nginx-autoinstall/master/nginx-autoinstall.sh
chmod +x nginx-autoinstall.sh
./nginx-autoinstall.sh
```

You will be able to:

- Install NGINX
- Update NGINX (It will install it again and overwrite current files and/or modules.)
- Uninstall NGINX with optional cleanup
- Self-update the script

Just follow the question!

You can check [configuration examples](https://github.com/angristan/nginx-autoinstall/tree/master/conf) for the custom modules.

## Headless use

You can run the script without the prompts with the option `HEADLESS` set to `y`. This allows for automated install and scripting. This is what is used to test the script with [GitHub Actions](https://github.com/angristan/nginx-autoinstall/actions/workflows/build.yml).

```sh
HEADLESS=y ./nginx-autoinstall.sh
```

To install Nginx mainline with Brotli:

```sh
HEADLESS=y \
NGINX_VER=MAINLINE \
BROTLI=y \
./nginx-autoinstall.sh
```

To install with Geoip:

```sh
HEADLESS=y \
GEOIP=y \
GEOIP2_ACCOUNT_ID=YOUR_ACCOUNT_ID_HERE \
GEOIP2_LICENSE_KEY=YOUR_LICENSE_KEY_HERE \
./nginx-autoinstall.sh
```

To uninstall Nginx and remove the logs and configuration files:

```sh
HEADLESS=y \
OPTION=2 \
RM_CONF=y \
RM_LOGS=y \
./nginx-autoinstall.sh
```

All the default variables are set at the beginning of the script.

## LICENSE

GPL v3.0
