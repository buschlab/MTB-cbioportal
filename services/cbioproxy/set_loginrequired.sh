#!/bin/sh

if [ ! -z "$NGINX_LOGINREQUIRED" ]
then
    cd /etc/nginx/conf.d
    cat cbioportal.conf | sed "s/set \$NGINX_LOGINREQUIRED.*/set \$NGINX_LOGINREQUIRED '"$NGINX_LOGINREQUIRED"';/" > tmp.txt
    cat tmp.txt > cbioportal.conf
    rm tmp.txt
    echo "set the NGINX_LOGINREQUIRED variable in the cbioportal.conf file to: $NGINX_LOGINREQUIRED"
else
    # variable $NGINX_LOGINREQUIRED is not known, so no need to change the file
    echo "environment variable NGINX_LOGINREQUIRED is not known"
fi


