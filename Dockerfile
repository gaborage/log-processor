FROM        openjdk:9-slim as build
RUN         apt-get update && apt-get install -y git
WORKDIR     /depot
RUN         git clone https://github.com/neowu/core-ng-project.git
RUN         cd core-ng-project && ./gradlew -Penv=prod :log-processor:installDist

FROM        openjdk:9-jre-slim
MAINTAINER  neo
LABEL       app=log-processor
EXPOSE      8080
RUN         addgroup app && adduser --no-create-home --ingroup app app
USER        app
WORKDIR     /opt
COPY        --from=build /depot/core-ng-project/build/log-processor/install/log-processor /opt/log-processor
ENTRYPOINT  ["/bin/sh", "-c", "/opt/log-processor/bin/log-processor"]
