#
# Copyright (c) 2016 The Hyve B.V.
# This code is licensed under the GNU Affero General Public License (AGPL),
# version 3, or (at your option) any later version.
# Adapted by Philipp Unberath
#

FROM tomcat:8-jre8
MAINTAINER Philipp Unberath <philipp.unberath@fau.de>

# install build and runtime dependencies and configure Tomcat for production
RUN apt-get update && apt-get install -y --no-install-recommends \
		git \
		libmysql-java \
		maven \
		openjdk-8-jdk \
		patch \
		python3 \
		python3-jinja2 \
		python3-mysqldb \
		python3-requests \
		python3-yaml \
	&& rm -rf /var/lib/apt/lists/* \
	&& ln -s /usr/share/java/mysql-connector-java.jar "$CATALINA_HOME"/lib/ \
	&& rm -rf $CATALINA_HOME/webapps/*m* 
	

# fetch the cBioPortal sources and version control metadata
ENV PORTAL_HOME=/cbioportal
RUN git clone --depth 1 -b v3.0.1 'https://github.com/cbioportal/cbioportal.git' $PORTAL_HOME
WORKDIR $PORTAL_HOME

#RUN git fetch --depth 1 https://github.com/thehyve/cbioportal.git my_development_branch \
#       && git checkout commit_hash_in_branch

# add buildtime configuration
COPY ./config/log4j.properties src/main/resources/log4j.properties

# build and install, placing the scripts jar back in the target folder
# where import scripts expect it after cleanup
RUN mvn -DskipTests clean install \
	&& unzip portal/target/cbioportal.war -d $CATALINA_HOME/webapps/cbioportal \
	&& mv scripts/target/scripts-*.jar /root/ \
	&& mvn clean \
	&& mkdir scripts/target/ \
	&& mv /root/scripts-*.jar scripts/target/

# add runtime plumbing to Tomcat config:
# - make cBioPortal honour db config in portal.properties
# temporarily add session.service.url here since it does not work in portal.properties
RUN echo 'CATALINA_OPTS="-Dauthenticate=false -Dsession.service.url=http://cbio-session-service:8080/api/sessions/main_session/ $CATALINA_OPTS -Ddbconnector=dbcp"' >>$CATALINA_HOME/bin/setenv.sh
# - tweak server-wide config file
COPY ./config/catalina_server.xml.patch /root/
RUN patch $CATALINA_HOME/conf/server.xml </root/catalina_server.xml.patch

# add importer scripts to PATH for easy running in containers
RUN find $PWD/core/src/main/scripts/ -type f -executable \! -name '*.pl'  -print0 | xargs -0 -- ln -st /usr/local/bin
# TODO: fix the workdir-dependent references to '../scripts/env.pl' and do this:
# RUN find $PWD/core/src/main/scripts/ -type f -executable \! \( -name env.pl -o -name envSimple.pl \)  -print0 | xargs -0 -- ln -st /usr/local/bin
