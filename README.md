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
- [Cloudflare's SPDY patch](https://blog.cloudflare.com/open-sourcing-our-nginx-http-2-spdy-code/) : enables the use of SPDY along with HTTP/2
- [Cloudflare's Chacha20 patch](https://blog.cloudflare.com/do-the-chacha-better-mobile-performance-with-cryptography/) : add the ChaCha20 + Poly1305 cipher suite
- [Cloudflare's TLS Dynamic Record Resizing patch](https://blog.cloudflare.com/optimizing-tls-over-tcp-to-reduce-latency/)
You can check the different versions [here](https://github.com/Angristan/nginx-autoinstall/tree/master/var)

## Installation

Just download and execute the script :
```
wget https://raw.githubusercontent.com/Angristan/nginx-autoinstall/master/nginx-autoinstall.sh
chmod +x nginx-autoinstall.sh
./nginx-autoinstall.sh
```

You can check [nginx.conf exemples](https://github.com/Angristan/nginx-autoinstall/tree/master/conf).

## Uninstallation

Just select the option when running the script :

![update](https://lut.im/Gbz5D0EH9Z/kbXb0nQ49NN52VI9.png)

You have te choice to delete the logs and the conf.

## Update

Select the update option to get the latest fixes and modules version. 

Warning : It will override all you modifications to the script !

![update](https://lut.im/CbjoOphOFa/RuLJ82QCnlnBIviW.png)

You can install nginx over and over again, to add or remove modules or just to update nginx.

## LICENSE

GPL v3.0
