FROM        openjdk:8-jdk as build
RUN         apt-get install -y git
WORKDIR     /depot
RUN         git clone https://github.com/neowu/core-ng-project.git
RUN         cd core-ng-project && ./gradlew -Penv=prod :log-processor:installDist

FROM        openjdk:jre-alpine
MAINTAINER  neo
EXPOSE      8080
WORKDIR     /opt
COPY        --from=build /depot/core-ng-project/build/log-processor/install/log-processor /opt/log-processor
ENTRYPOINT  ["/bin/sh", "-c", "/opt/log-processor/bin/log-processor"]
