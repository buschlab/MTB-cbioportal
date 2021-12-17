#!/bin/bash
echo 'Extracting HAPI database from dump'
sed '/\\connect hapi/,$!d' dump.sql > dump_hapi.sql
echo 'Stopping an deleting hapiserver and hapi-postgres containers'
docker-compose stop hapiserver hapi-postgres && docker-compose rm -f hapiserver hapi-postgres
echo 'Removing volume from hapi-postgres'
docker volume rm -f miracum-cbioportal_fhir_data
echo 'Starting hapi-postgres'
docker-compose up -d hapi-postgres
echo 'Waiting for hapi-postgres to come up'
sleep 20
echo 'Importing dumped HAPI database'
docker-compose exec -T hapi-postgres psql -U hapiserver -d hapi < dump_hapi.sql
rm dump_hapi.sql
echo 'Starting hapiserver'
docker-compose up -d hapiserver