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
