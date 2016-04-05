# nginx-autoinstall
Automatically compile from source and install Nginx mainline, on Debian 8.

## Features
- Latest mainline version (1.9.14), from source
- Optional modules (see below)
- Removed useless modules
- [Custom nginx.conf](https://github.com/Angristan/nginx-autoinstall/blob/master/conf/nginx.conf) (default does not work)
- [Init script for systemd](https://github.com/Angristan/nginx-autoinstall/blob/master/conf/nginx.service) (not privded by default)

### Optional modules
- [LibreSSL](https://github.com/libressl-portable/portable) 2.3.3 (HTTP/2 + ALPN support)
- [ngx_pagespeed](https://github.com/pagespeed/ngx_pagespeed) 1.11.33.0
- [ngx_brotli](https://github.com/google/ngx_brotli)
- [ngx_headers_more](https://github.com/openresty/headers-more-nginx-module) 0.29

## Installation

Just download and execute the script :
```
wget --no-check-certificate https://bit.ly/nginx-autoinstall -O nginx-autoinstall.sh
chmod +x nginx-autoinstall.sh
./nginx-autoinstall.sh
```

You can check [nginx.conf exemples](https://github.com/Angristan/nginx-autoinstall/tree/master/conf).

## Update

Just re-lauch the script. (you may re-download it if I made changes with the command above)

You can install nginx over and over again, to add or remove modules or just to update nginx.

## LICENSE

GPL v3.0
