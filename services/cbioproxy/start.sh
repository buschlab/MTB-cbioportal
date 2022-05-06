#!/bin/ash
cp /certs/* /usr/local/share/ca-certificates/
rm /usr/local/share/ca-certificates/.gitkeep
update-ca-certificates
/usr/local/openresty/bin/openresty -g "daemon off;"