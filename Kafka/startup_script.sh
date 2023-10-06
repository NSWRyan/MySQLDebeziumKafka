#!/bin/bash

/bin/sh -c 'nohup {{ USER_HOME }}/kafka/bin/zookeeper-server-start.sh {{ USER_HOME }}/kafka/config/zookeeper.properties > {{ USER_HOME }}/logs/zookeeper_service.log 2>&1 &'
sleep 20
/bin/sh -c '{{ USER_HOME }}/kafka/bin/kafka-server-start.sh {{ USER_HOME }}/kafka/config/server.properties > {{ USER_HOME }}/logs/kafka_service.log 2>&1'
