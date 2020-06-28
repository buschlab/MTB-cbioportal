FROM maven:3-openjdk-11 as build
LABEL maintainer="Niklas Reimer <niklas@nr205.de>"

RUN apt update && apt install git -y

RUN git clone https://github.com/nr23730/fhirspark.git /fhirspark
WORKDIR /fhirspark
RUN mvn -DskipTests clean package


FROM openjdk:11-jre-slim

COPY --from=build /fhirspark/target/fhirspark-*-jar-with-dependencies.jar /app.jar

CMD ["java", "-jar", "/app.jar"]
