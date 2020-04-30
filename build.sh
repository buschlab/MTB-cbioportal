#!/bin/sh
docker build -t docker.miracum.org/cbioportal/$1:${RELEASE:-latest} ./services/$1
