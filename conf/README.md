# Configurations files.

### PageSpeed

Add this in you http block :

```
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
More info here : https://angristan.fr/compiler-installer-nginx-module-pagespeed-debian/

### Brotli

Add this in your http block :

```
brotli on;
        brotli_static on;
        brotli_buffers 16 8k;
        brotli_comp_level 6;
        brotli_types
                text/css
                text/javascript
                text/xml
                text/plain
                text/x-component
                application/javascript
                application/x-javascript
                application/json
                application/xml
                application/rss+xml
                application/atom+xml
                application/rdf+xml
                application/vnd.ms-fontobject
                font/truetype
                font/opentype
                image/svg+xml;
```

### LibreSSL 

Add this cipher suite in you server block :

`ssl_ciphers EECDH+CHACHA20:EECDH+AESGCM:EECDH+AES;`

### Cloudflare's ChaCha20 patch

Add this cipher suite in your server block :

`EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AESGCM:EECDH+AES;`

### Cloudflare's SPDY patch

You can add this in your HTTPS server block :

`listen  443 ssl spdy http2;`

### GeoIP

Add the path of the 2 GeoIP databases to your http block :

```
geoip_country  /opt/geoip-db/GeoIP-Country.dat;
geoip_city     /opt/geoip-db/GeoIP-City.dat;
```
