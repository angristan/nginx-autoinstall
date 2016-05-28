# nginx-autoinstall
Automatically compile from source and install Nginx mainline, on Debian 8.

![screen](https://lut.im/0bANC53xTu/DIob0ZeX2wG2vdAW.png)
## Features
- Latest mainline version, from source
- Optional modules (see below)
- Removed useless modules
- [Custom nginx.conf](https://github.com/Angristan/nginx-autoinstall/blob/master/conf/nginx.conf) (default does not work)
- [Init script for systemd](https://github.com/Angristan/nginx-autoinstall/blob/master/conf/nginx.service) (not provided by default)
- [Logrotate conf](https://github.com/Angristan/nginx-autoinstall/blob/master/conf/nginx-logrotate) (not provided by default)

### Optional modules/features
- [LibreSSL](http://www.libressl.org/) (ChaCha20 cipher, HTTP/2 + ALPN support)
- [OpenSSL](https://www.openssl.org/) from source (HTTP/2 + ALPN support)
- [ngx_pagespeed](https://github.com/pagespeed/ngx_pagespeed)
- [ngx_brotli](https://github.com/google/ngx_brotli)
- [ngx_headers_more](https://github.com/openresty/headers-more-nginx-module)
- [GeoIP](http://dev.maxmind.com/geoip/geoip2/geolite2/) module and databases
- [Cloudflare's SPDY patch](https://github.com/felixbuenemann/sslconfig/blob/b8ebac6a337e8e4e373dfee76e7dfac3cc6c56e6/patches/nginx_1_9_15_http2_spdy.patch) : enables the use of SPDY along with HTTP/2
- [Cloudflare's Chacha20 patch](https://github.com/cloudflare/sslconfig/blob/master/patches/openssl__chacha20_poly1305_draft_and_rfc_ossl102g.patch) : add the ChaCha20 + Poly1305 cipher suite

You can check the different versions [here](https://github.com/Angristan/nginx-autoinstall/tree/master/var)
## Installation

Just download and execute the script :
```
wget --no-check-certificate https://bit.ly/nginx-autoinstall -O nginx-autoinstall.sh
chmod +x nginx-autoinstall.sh
./nginx-autoinstall.sh
```

You can check [nginx.conf exemples](https://github.com/Angristan/nginx-autoinstall/tree/master/conf).

## Update

Just re-launch the script.

If change was made to this repository, you may re-download the script.

You can install nginx over and over again, to add or remove modules or just to update nginx.

## LICENSE

GPL v3.0
