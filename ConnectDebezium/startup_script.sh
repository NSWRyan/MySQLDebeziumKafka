#!/bin/bash

# Wait until Kafka is fully up
sleep 30
/bin/sh -c '{{ USER_HOME }}/kafka/bin/connect-distributed.sh {{ USER_HOME }}/kafka/config/connect-distributed.properties  > {{ USER_HOME }}/logs/connect_service.log 2>&1'
