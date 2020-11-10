# miracum-cbioportal

## Installation

Ein OncoKB Token kann [hier](https://www.oncokb.org/apiAccess) angefordert werden. Diese muss in die `.env` Datei eintegraten werden.

Initialisierung einmalig starten:
```
sudo ./build.sh cbioportal && docker-compose -f init.yml up
```

Starten der Development-Version:
```
sudo ./sudo docker-compose -f docker-compose-dev.yml up
```

**Der erste Startvorgang dauert ca. 15 Minuten**, da hierbei initial drei Docker Images gebaut werden. Nachfolgende Startvorgänge sind deutlich schneller.

Einzelne Dienste (`cbioportal`, `cbioproxy`, `fhirspark`, `genome-nexus`, `genome-nexus-vep`) können über den Befehl
```
sudo ./build.sh <Dienstname>
```
neu gebaut werden.

### Import von Studien

```
docker-compose run cbioportal metaImport.py -u http://cbioportal:8080 -s /study/testpatient -o
```

#### Import der öffentlichen Datenbank (optional)

1. Löschen der Datenbank
```
echo "drop database cbioportal; create database cbioportal;" | docker exec -i cbioportal_database_container mysql -uroot -pP@ssword1
```

2. Import der Studiendatenbank
```
zcat public-portal-dump.latest.sql.gz | docker exec -i cbioportal_database_container mysql -uroot -pP@ssword1 cbioportal
```

## Komponenten

- NGINX Reverse Proxy
- cBioPortal
  - MariaDB Datenbank
- cBioPortal Session Service
  - Mongo DB
- Genome-Nexus
  - Mongo DB
  - VEP
- FHIRspark
  - HAPI FHIR Server
  - PostgreSQL Server

## Ports

| Dienst | Pfad (hinter NGINX) | Port (docker-compose-dev.yml) |
| - | - | - |
| NGINX  | / | 8080 |
| cBioPortal | / | 8081 |
| cBioPortal Debugger | - | 5005 |
| MariaDB-Datenbank | - | 3306 |
| Session Service | - | 5000 |
| Genome-Nexus | /genome-nexus | 8888 |
| Genome-Nexus-VEP | - | 6060 |
| Mongo DB | - | 27017 |
| FHIRspark | /mtb/ | 3001 |
| HAPI FHIR Server | /fhir/ | 8082 |
| PostgreSQL Server | - | 5432 |

## Debugging

An das Backend von cBioPortal kann ein Debugger angehängt werden. Für Visual Studio Code existiert bereits eine [Konfiguration](https://github.com/cBioPortal/cbioportal/blob/master/README.md#%EF%B8%8F%EF%B8%8F-debugging).
