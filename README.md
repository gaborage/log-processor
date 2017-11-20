## Overview
log-processor is used by core-ng framework, which is designed to support our own projects.
for more info please refer to [https://github.com/neowu/core-ng-project](https://github.com/neowu/core-ng-project)

## docker-compose example
```
version: "3"
services:
  elasticsearch:
    image: docker.elastic.co/elasticsearch/elasticsearch:6.0.0
    ports:
      - 9200:9200
      - 9300:9300
    environment:
      - cluster.name=log
      - http.host=0.0.0.0
      - transport.host=0.0.0.0
      - ES_JAVA_OPTS=-Xms512m -Xmx512m
      - xpack.security.enabled=false
  kibana:
    image: docker.elastic.co/kibana/kibana:6.0.0
    ports:
      - 5601:5601
    environment:
      - ELASTICSEARCH_URL=http://elasticsearch:9200
      - xpack.security.enabled=false
    depends_on:
      - elasticsearch
  zookeeper:
    image: zookeeper
    ports:
      - 2181
  kafka:
    image: neowu/kafka:1.0.0
    ports:
      - 9092:9092
    environment:
      - KAFKA_ARGS=--override advertised.listeners=PLAINTEXT://kafka:9092
    depends_on:
      - zookeeper
  log-processor:
    image: neowu/log-processor:5.2.4
    environment:
      - ELASTICSEARCH_HOST=elasticsearch
      - KAFKA_URI=kafka:9092
      - JAVA_OPTS=-XX:+UseG1GC -Xms256m -Xmx2048m -Xss256k -Djava.awt.headless=true
    depends_on:
      - kafka
      - elasticsearch
```

## Kubernetes example:
```
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: log-processor
  namespace: dev
spec:
  replicas: 1
  revisionHistoryLimit: 3
  strategy:
    rollingUpdate:
      maxUnavailable: 0
      maxSurge: 1
  template:
    metadata:
      labels:
        app: log-processor
    spec:
      nodeSelector:
        pool: ops
      containers:
      - name: log-processor
        image: neowu/log-processor:5.2.4
        env:
        - name: JAVA_OPTS
          value: "-XX:+UseG1GC -Xmx512m -Xss256k -XX:ParallelGCThreads=2 -XX:ConcGCThreads=2 -Djava.awt.headless=true -Dcore.availableProcessors=2"
        - name: ELASTICSEARCH_HOST
          value: "log-es-0.log-es"
        - name: KAFKA_URI
          value: "log-kafka-0.log-kafka:9092"
        ports:
        - containerPort: 8080
        livenessProbe:
          httpGet:
            path: /health-check
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 10
```
