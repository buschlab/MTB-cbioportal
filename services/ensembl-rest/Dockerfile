FROM ensemblorg/ensembl-vep:release_103
LABEL maintainer="Niklas Reimer <niklas.reimer@uksh.de>"

USER root
RUN apt-get update && apt-get install -y git libcatalyst-devel-perl libxml-simple-perl libtest-xml-simple-perl
WORKDIR /opt/vep/src

RUN git clone https://github.com/Ensembl/ensembl-compara.git
ENV PERL5LIB=/opt/vep/src/ensembl-vep:/opt/vep/src/ensembl-vep/modules:/opt/vep/src/ensembl-compara/modules

RUN git clone https://github.com/Ensembl/ensembl-rest.git /opt/vep/src/ensembl-rest
WORKDIR /opt/vep/src/ensembl-rest
RUN cpanm --installdeps .

RUN mv /opt/vep/src/ensembl-rest/ensembl_rest.conf.default /opt/vep/src/ensembl-rest/ensembl_rest.conf

EXPOSE 3000

USER vep

WORKDIR /opt/vep/src/ensembl-vep/
RUN ./INSTALL.pl -n -a cf -s homo_sapiens -y GRCh37

ENTRYPOINT ["perl", "/opt/vep/src/ensembl-rest/script/ensembl_rest_server.pl"]
