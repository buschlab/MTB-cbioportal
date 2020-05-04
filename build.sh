#!/bin/sh
docker build --no-cache -t docker.miracum.org/cbioportal/$1:${RELEASE:-latest} ./services/$1
