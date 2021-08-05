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
    
FROM openliberty/open-liberty:full-java11-openj9-ubi

ARG VERSION=1.0
ARG REVISION=SNAPSHOT

RUN mkdir -p /opt/ol/wlp/usr/shared/resources/

LABEL \
  org.opencontainers.image.authors="Your Name" \
  org.opencontainers.image.vendor="Open Liberty" \
  org.opencontainers.image.url="local" \
  org.opencontainers.image.source="https://github.com/OpenLiberty/guide-sessions" \
  org.opencontainers.image.version="$VERSION" \
  org.opencontainers.image.revision="$REVISION" \
  vendor="Open Liberty" \
  name="cart-app" \
  version="$VERSION-$REVISION" \
  summary="The cart application from the Sessions guide" \
  description="This image contains the cart application running with the Open Liberty runtime."

COPY --chown=1001:0 --from=build-stage /config /config/
COPY --chown=1001:0 --from=build-stage /config/apps/hazelcast-*.jar /opt/ol/wlp/usr/shared/resources/hazelcast.jar

RUN configure.sh
