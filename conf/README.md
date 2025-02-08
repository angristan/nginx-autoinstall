# Headless

- Change `=n` to `=y` to enable modules individually
- Version numbers are configurable
- Custom options in `NGINX_OPTIONS=`
  - See [Installation and Compile-Time Options](https://www.nginx.com/resources/wiki/start/topics/tutorials/installoptions/)
  - Change between stable and mainline with:
    `NGINX_VER=STABLE` or `NGINX_VER=MAINLINE`
  - Change between SSL with:
    `SYSTEM`, `OPENSSL` or `LIBRESSL`

- Custom/dynamic modules can be loaded in `NGINX_MODULES=`
  - See [NGINX 3rd Party Modules](https://www.nginx.com/resources/wiki/modules/)
  - Example: Download to /usr/local/src/nginx-custom-modules
  - Load the module with `--add-module=/usr/local/src/nginx-custom-modules/module-name`
  in `NGINX_MODULES=` like so:

```shell
  NGINX_MODULES="--add-module=/usr/local/src/nginx-custom-modules/module-name" \
```

Starting from NGINX 1.9.11, you can also compile modules as a dynamic module:

```shell
  NGINX_MODULES=
  "--add-dynamic-module=/usr/local/src/nginx-custom-modules/module-name" \
```

Then you can explicitly load the module in your `nginx.conf`
via the [load_module](http://nginx.org/en/docs/ngx_core_module.html#load_module)
directive, for example,

```shell
load_module /usr/local/src/nginx-custom-modules/module-name_module.so;
```

## Full headless config

```shell
HEADLESS=y \
NGINX_VER=STABLE \
PAGESPEED=n \
BROTLI=n \
HEADERMOD=n \
GEOIP=n \
GEOIP2_ACCOUNT_ID=YOUR_ACCOUNT_ID_HERE \
GEOIP2_LICENSE_KEY=YOUR_LICENSE_KEY_HERE \
FANCYINDEX=n \
CACHEPURGE=n \
SUBFILTER=n \
LUA=n \
WEBDAV=n \
VTS=n \
RTMP=n \
TESTCOOKIE=n \
HTTP3=n \
MODSEC=n \
REDIS2=n \
HTTPREDIS=n \
SRCACHE=n \
SETMISC=n \
NGXECHO=n \
HPACK=n \
SSL=SYSTEM \
RM_CONF=n \
RM_LOGS=n \
NGINX_MAINLINE_VER=1.21.6 \
NGINX_STABLE_VER=1.20.1 \
LIBRESSL_VER=3.3.1 \
OPENSSL_VER=1.1.1l \
NPS_VER=1.13.35.2 \
HEADERMOD_VER=0.33 \
LIBMAXMINDDB_VER=1.4.3 \
GEOIP2_VER=3.3 \
LUA_JIT_VER=2.1-20220310 \
LUA_NGINX_VER=0.10.21rc2 \
LUA_RESTYCORE_VER=0.1.23rc1 \
LUA_RESTYLRUCACHE_VER=0.11 \
NGINX_DEV_KIT=0.3.1 \
HTTPREDIS_VER=0.3.9 \
NGXECHO_VER=0.62 \
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
  --with-cc-opt=-Wno-ignored-qualifiers" \
NGINX_MODULES="--with-threads \
  --with-file-aio \
  --with-http_ssl_module \
  --with-http_v2_module \
  --with-http_mp4_module \
  --with-http_auth_request_module \
  --with-http_slice_module \
  --with-http_stub_status_module \
  --with-http_realip_module \
  --with-http_sub_module" \
./nginx-autoinstall.sh 2>&1 | tee nginx-installer.log
```

## Configurations files

### PageSpeed

Add this in your http block:

```nginx
pagespeed on;
pagespeed StatisticsPath /ngx_pagespeed_statistics;
pagespeed GlobalStatisticsPath /ngx_pagespeed_global_statistics;
pagespeed MessagesPath /ngx_pagespeed_message;
pagespeed ConsolePath /pagespeed_console;
pagespeed AdminPath /pagespeed_admin;
pagespeed GlobalAdminPath /pagespeed_global_admin;
# Needs to exist and be writable by nginx.
# Use tmpfs for best performance.
pagespeed FileCachePath /var/ngx_pagespeed_cache;
```

More info here : <https://angristan.fr/compiler-installer-nginx-module-pagespeed-debian/>

### Brotli

Add this in your http block :

```nginx
brotli on;
brotli_static on;
brotli_buffers 16 8k;
brotli_comp_level 6;
brotli_types *;
```

### LibreSSL / OpenSSL 1.1+

You can now use ChaCha20 in addition to AES. Add this in your server block:

```nginx
ssl_ciphers EECDH+CHACHA20:EECDH+AESGCM:EECDH+AES;
```

You can also use more secure curves :

```nginx
ssl_ecdh_curve X25519:P-521:P-384:P-256;
```

### TLS 1.3

TLS 1.3 needs special ciphers.

```nginx
ssl_protocols TLSv1.3 TLSv1.2;
ssl_ciphers TLS-CHACHA20-POLY1305-SHA256:TLS-AES-256-GCM-SHA384:TLS-AES-128-GCM-SHA256:EECDH+CHACHA20:EECDH+AESGCM:EECDH+AES;
```

TLS- can be TLS13-.

### GeoIP 2

See <https://github.com/leev/ngx_http_geoip2_module#example-usage>

### HTTP/3

See <https://github.com/cloudflare/quiche/tree/master/extras/nginx#readme>

```nginx
server {
    # Enable QUIC and HTTP/3.
    listen 443 quic reuseport;

    # Enable HTTP/2 (optional).
    listen 443 ssl http2;

    ssl_certificate      cert.crt;
    ssl_certificate_key  cert.key;

    # Enable all TLS versions (TLSv1.3 is required for QUIC).
    ssl_protocols TLSv1.2 TLSv1.3;

    # Add Alt-Svc header to negotiate HTTP/3.
    add_header alt-svc 'h3-23=":443"; ma=86400';
}
```

### Testcookie

Example configuration in nginx.conf:

```nginx
#default config, module disabled
testcookie off;
#setting cookie name
testcookie_name TCK;
#setting secret
testcookie_secret random;
#setting session key
testcookie_session $remote_addr;
#setting argument name
testcookie_arg ckattempt;
#setting maximum number of cookie setting attempts
testcookie_max_attempts 3;
#setting p3p policy
testcookie_p3p 'CP="CUR ADM OUR NOR STA NID", policyref="/w3c/p3p.xml"';
#setting fallback url
testcookie_fallback /cookies.html?backurl=http://$host$uri?$query_string;

#configuring whitelist
testcookie_whitelist {
    1.1.1.1/32;
}
#Process only GET requests, POST requests will be bypassed.
testcookie_get_only off;
#Close connection just after setting the cookie, no reason to keep connections with bots.
testcookie_deny_keepalive on;
#setting redirect via html code
testcookie_redirect_via_refresh off;
#enable encryption
testcookie_refresh_encrypt_cookie on;
#setting encryption key
testcookie_refresh_encrypt_cookie_key random;
#setting encryption iv
testcookie_refresh_encrypt_cookie_iv xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
#setting response template
testcookie_refresh_template '<html><body>setting cookie...<script type=\"text/javascript\" src=\"/aes.min.js\" ></script><script>function toNumbers(d){var e=[];d.replace(/(..)/g,function(d){e.push(parseInt(d,16))});return e}function toHex(){for(var d=[],d=1==arguments.length&&arguments[0].constructor==Array?arguments[0]:arguments,e="",f=0;f<d.length;f++)e+=(16>d[f]?"0":"")+d[f].toString(16);return e.toLowerCase()}var a=toNumbers("$testcookie_enc_key"),b=toNumbers("$testcookie_enc_iv"),c=toNumbers("$testcookie_enc_set");document.cookie="TCK="+toHex(slowAES.decrypt(c,2,a,b))+"; expires=Thu, 31-Dec-37 23:55:55 GMT; path=/";location.href="$testcookie_nexturl";</script></body></html>';

```

```nginx
# Whitelisting testcookie with "map"
map $remote_addr $trusted {
    default          0;
    "127.0.0.1"      1; # localhost
}
```

And in server block:

```nginx
location / {
.....
    testcookie on;
    testcookie_pass $trusted;
.....
}
```

Notice the

```nginx
# setting redirect via html code
testcookie_redirect_via_refresh off;
```

Which turns off the html part.

See <https://github.com/kyprizel/testcookie-nginx-module#testcookie_redirect_via_refresh>
