#!/usr/bin/env bash

cat /cbioportal-webapp/application.properties.EXAMPLE | \
    sed 's/spring.datasource.username=.*/spring.datasource.username=cbio/g' | \
    sed 's/spring.datasource.password=.*/spring.datasource.password='"$MYSQL_USER_PASSWORD"'/g' | \
    sed 's|spring.datasource.url=.*|spring.datasource.url=jdbc:mysql://cbioportal_database:3306/cbioportal|g' \
> application.properties
cp /cbioportal-webapp/security.properties.EXAMPLE security.properties
cp /etc/ssl/certs/java/cacerts cacerts
keytool -import -trustcacerts -keystore cacerts -storepass changeit -noprompt -alias keycloak -file /config/keycloak.pem