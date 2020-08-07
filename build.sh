#!/bin/bash
if [ $1 == "cbioportal" ];
then
  docker build --no-cache --pull -t docker.miracum.org/cbioportal/$1:${RELEASE:-latest} ./services/$1
  docker build --no-cache -t docker.miracum.org/cbioportal/cbioproxy:${RELEASE:-latest} ./services/cbioproxy
elif [ $1 == "cbioproxy" ];
then
  docker build --no-cache -t docker.miracum.org/cbioportal/cbioproxy:${RELEASE:-latest} ./services/cbioproxy
else
  docker build --no-cache --pull -t docker.miracum.org/cbioportal/$1:${RELEASE:-latest} ./services/$1
fi
