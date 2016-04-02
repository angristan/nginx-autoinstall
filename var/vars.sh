#!/bin/bash
# If you want to check the latest version of Nginx/modules, you can use these commands. 
# I don't know if I'm gonna put them in the script...

curl -s http://nginx.org/en/CHANGES | awk 'NR==2' | awk '{print $4}'
curl -s https://raw.githubusercontent.com/libressl-portable/portable/master/ChangeLog | awk 'NR==31' | awk '{print $1}'
curl -s https://developers.google.com/speed/pagespeed/module/build_ngx_pagespeed_from_source | grep NPS_VERSION= | cut -c13-22
