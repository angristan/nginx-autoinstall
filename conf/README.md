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
        brotli_types *;
```

### LibreSSL / OpenSSL from source

You can now use ChaCha20 in addition to AES. Add this in your server block:

`ssl_ciphers EECDH+CHACHA20:EECDH+AESGCM:EECDH+AES;`

You can also use more secure curves :

`ssl_ecdh_curve X25519:P-521:P-384:P-256;`

### Dynamic TLS Records

Add this into your http block to enable the patch:

`ssl_dyn_rec_enable on;`


### GeoIP

Add the path of the 2 GeoIP databases to your http block:

```
geoip_country  /opt/geoip-db/GeoIP-Country.dat;
geoip_city     /opt/geoip-db/GeoIP-City.dat;
```
