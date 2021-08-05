FROM adoptopenjdk/openjdk8-openj9 AS build-stage

RUN apt-get update && \
    apt-get install -y maven unzip

COPY . /project
WORKDIR /project

#RUN mvn -X initialize process-resources verify => to get dependencies from maven
#RUN mvn clean package	
#RUN mvn --version
RUN mvn clean package

RUN mkdir -p /config/apps && \
    mkdir -p /sharedlibs && \
    cp ./src/main/liberty/config /config && \
    cp ./target//*.*ar /config/apps/ && \
    if [ ! -z "$(ls ./src/main/liberty/lib)" ]; then \
        cp ./src/main/liberty/lib/* /sharedlibs; \
    fi
    
FROM openliberty/open-liberty:kernel-slim-java8-openj9-ubi

ARG TLS=true

RUN mkdir -p /opt/ol/wlp/usr/shared/resources/

COPY --chown=1001:0 --from=build-stage /config /config/
COPY --chown=1001:0 --from=build-stage /config/apps/hazelcast-*.jar /opt/ol/wlp/usr/shared/resources/hazelcast.jar

RUN features.sh

RUN configure.sh
