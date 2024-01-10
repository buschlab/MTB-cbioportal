FROM docker.io/maven:3-openjdk-11 as build
RUN git clone https://github.com/genome-nexus/genome-nexus.git /genome-nexus
WORKDIR /genome-nexus
RUN mvn -DskipTests clean install

FROM gcr.io/distroless/java11-debian11
LABEL maintainer="Niklas Reimer <niklas.reimer@uksh.de>"
COPY --from=build /genome-nexus/web/target/*.war /app/genome-nexus.war
ENTRYPOINT ["java"]
CMD ["-Dspring.data.mongodb.uri=${MONGODB_URI}", "-jar", "/app/genome-nexus.war"]
