FROM maven:3.5.4
RUN mkdir /genome-nexus-vep
RUN git clone https://github.com/genome-nexus/genome-nexus-vep /genome-nexus-vep
WORKDIR /genome-nexus-vep
RUN mvn -DskipTests clean install

FROM ensemblorg/ensembl-vep:release_98.3
USER root
RUN apt-get update && apt-get -y install openjdk-8-jre
COPY --from=0 /genome-nexus-vep/target/vep_wrapper*.jar /opt/vep/src/ensembl-vep/vep_wrapper.jar
USER vep
WORKDIR /opt/vep/src/ensembl-vep/
RUN ./INSTALL.pl -n -a cf -s homo_sapiens -y GRCh37
ENTRYPOINT exec java ${JAVA_OPTS} -jar vep_wrapper.jar
