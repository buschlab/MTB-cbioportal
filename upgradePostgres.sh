#!/bin/bash

echo 'Which container environment are you using? {docker, podman}'
read CONTAINER

echo 'Extracting HAPI database from dump'
sed '/\\connect hapi/,$!d' dump.sql > dump_hapi.sql
echo 'Stopping an deleting hapiserver and hapi-postgres containers'
$CONTAINER-compose stop cbioproxy hapiserver hapi-postgres
$CONTAINER rm -f cbioproxy_container
$CONTAINER rm -f cbioportal_fhirspark
$CONTAINER rm -f cbioportal_fhirspark_hapiserver
$CONTAINER rm -f cbioportal_fhirspark_database
echo 'Removing volume from hapi-postgres'
$CONTAINER volume rm -f miracum-cbioportal_fhir_data
echo 'Starting hapi-postgres'
$CONTAINER-compose up -d hapi-postgres
echo 'Waiting for hapi-postgres to come up'
sleep 20
echo 'Importing dumped HAPI database'
$CONTAINER-compose exec -T hapi-postgres psql -U hapiserver -d hapi < dump_hapi.sql
echo 'Starting hapiserver'
$CONTAINER-compose up -d hapiserver cbioproxy
