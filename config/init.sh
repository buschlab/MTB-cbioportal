#!/usr/bin/env bash

cat /cbioportal-webapp/WEB-INF/classes/portal.properties | \
    sed 's/db.host=.*/db.host=cbioportal_database:3306/g' | \
    sed 's/db.user=.*/db.user=cbio/g' | \
    sed 's/db.password=.*/db.password='"$MYSQL_USER_PASSWORD"'/g' | \
    sed 's|db.connection_string=.*|db.connection_string=jdbc:mysql://cbioportal_database:3306/|g' \
> portal.properties
