#!/bin/bash

export HEADLESS=y

if [[ $INSTALL_TYPE == "FULL" ]]; then
    export PAGESPEED=y
    export BROTLI=y
    export HEADERMOD=y
    export GEOIP=n # requires license key
    export FANCYINDEX=y
    export CACHEPURGE=y
    export SUBFILTER=y
    export LUA=y
    export WEBDAV=y
    export VTS=y
    export RTMP=y
    export TESTCOOKIE=y
    export HTTP3=y
    export MODSEC=y
    export HPACK=y
    export REDIS2=y
    export HTTPREDIS=y
    export SRCACHE=y
    export SETMISC=y
    export NGXECHO=y
fi

bash -x ../../nginx-autoinstall.sh
