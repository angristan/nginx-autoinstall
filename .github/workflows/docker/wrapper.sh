#!/bin/bash

export HEADLESS=y

if [[ $INSTALL_TYPE == "FULL" ]]; then
    export PAGESPEED=y
    export BROTLI=y
    export HEADERMOD=y
    export GEOIP=n # broken
    export FANCYINDEX=y
    export CACHEPURGE=y
    export SUBFILTER=y
    export LUA=n # broken
    export WEBDAV=y
    export VTS=y
    export RTMP=y
    export TESTCOOKIE=y
    export HTTP3=y
    export MODSEC=y
    export HPACK=y
    export RTMP=y
    export SUBFILTER=y
fi

bash -x ../../nginx-autoinstall.sh
