FROM maven:3-openjdk-11 as build
RUN git clone https://github.com/nr23730/fhirspark.git /fhirspark
WORKDIR /fhirspark
RUN mvn -DskipTests clean package

FROM gcr.io/distroless/java-debian10:11
LABEL maintainer="Niklas Reimer <niklas.reimer@uksh.de>"
COPY --from=build /fhirspark/target/fhirspark-*-jar-with-dependencies.jar /app/fhirspark.jar
CMD ["/app/fhirspark.jar"]
