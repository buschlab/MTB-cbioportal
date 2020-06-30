# This image includes both the web app and the data import related scripts in
# one image. Because of historic reasons some of these scripts run java
# artifacts under the hood. It therefore currently makes more sense to have a
# single image supporting both instead of moving the scripts out to a separate
# container.
#
# Use from root directory of repo like:
#
# docker build -f docker/web-and-data/Dockerfile -t cbioportal-container:tag-name .
#
# NOTE: the .git folder is included in the build stage, but excluded 
# from the final image. No confidential information is exposed.
# (see: stackoverflow.com/questions/56278325)
FROM maven:3-openjdk-11 as build

RUN git clone --single-branch --branch therapy_recommendation https://github.com/nr23730/cbioportal.git /cbioportal
WORKDIR /cbioportal
RUN mvn -DskipTests clean install

FROM openjdk:11-jre-slim

# download system dependencies first to take advantage of docker caching
RUN apt-get update; apt-get install -y --no-install-recommends \
        build-essential \
        default-mysql-client \
        default-libmysqlclient-dev \
        python3 \
        python3-setuptools \
        python3-dev \
        python3-pip \
        unzip \
	&& rm -rf /var/lib/apt/lists/* \
    && pip3 install wheel

ENV PORTAL_WEB_HOME=/cbioportal-webapp

RUN mkdir -p /cbioportal
COPY --from=build /cbioportal/portal/target/cbioportal*.war /app.war
COPY --from=build /cbioportal/portal/target/dependency/webapp-runner.jar /webapp-runner.jar
# copy over core jar and scripts
COPY --from=build /cbioportal/core /cbioportal/core
COPY --from=build /cbioportal/scripts /cbioportal/scripts
COPY --from=build /cbioportal/db-scripts /cbioportal/db-scripts
COPY --from=build /cbioportal/requirements.txt /cbioportal/requirements.txt

# install build and runtime dependencies
# ignore update failures
RUN  pip3 install -r /cbioportal/requirements.txt

# add importer scripts to PATH for easy running in containers
RUN find /cbioportal/core/src/main/scripts/ -type f -executable \! -name '*.pl'  -print0 | xargs -0 -- ln -st /usr/local/bin

# put config files in this folder if you want to override config
ENV PORTAL_HOME=/cbioportal

RUN mkdir -p $PORTAL_WEB_HOME
RUN unzip /app.war -d  $PORTAL_WEB_HOME

# script for calling dumpPortalInfo.py from docker-compose
RUN echo "cd /cbioportal/core/src/main/scripts && ./dumpPortalInfo.pl \$1" >> /cbioportal/dumpPortalInfo.sh
