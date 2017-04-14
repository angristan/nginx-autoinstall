# Configurations files.

### PageSpeed

Add this in your http block:

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

### LibreSSL / OpenSSL from source

You can now use ChaCha20 in addition to AES. Add this in your server block:

`ssl_ciphers EECDH+CHACHA20:EECDH+AESGCM:EECDH+AES;`

### Dynamic TLS Records

Add this into your http block to enable the patch:

`ssl_dyn_rec_enable on;`


### GeoIP

Add the path of the 2 GeoIP databases to your http block:

```
geoip_country  /opt/geoip-db/GeoIP-Country.dat;
geoip_city     /opt/geoip-db/GeoIP-City.dat;
```
