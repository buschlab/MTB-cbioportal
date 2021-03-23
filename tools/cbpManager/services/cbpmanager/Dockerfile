## Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest
LABEL maintainer="Arsenij Ustjanzew <arsenij.ustjanzew@uni-mainz.de>"

## system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

## install app dependencies
RUN R -e "install.packages('remotes', repos = 'http://cran.us.r-project.org')"
RUN R -e "remotes::install_github('arsenij-ust/cbpManager', dependencies=TRUE)"
RUN R -e "cbpManager::setupConda_cbpManager()"

## Clean up existing sample apps
RUN rm -rf /srv/shiny-server/[0-9][0-9]_* /srv/shiny-server/index.html /srv/shiny-server/sample-apps

## Create log directory
RUN mkdir /srv/shiny-server/log

EXPOSE 3838

## run app on container start
CMD ["R", "-e", "cbpManager::cbpManager(studyDir='/srv/shiny-server/study', logDir='/srv/shiny-server/log', host = '0.0.0.0', port = 3838)"]
