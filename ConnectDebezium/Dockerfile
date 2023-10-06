FROM ubuntu:mantic-20230912

RUN apt-get update && \
    apt-get -y install  libssl-dev \
                    libbz2-dev \
                    libffi-dev \
                    openssh-server \ 
                    openssh-client \
                    systemd \
                    systemd-sysv \
                    cron \
                    openjdk-17-jdk && \
    apt-get clean all

# Env setup
ENV DBZUSER=dbzuser
ENV ROOT_HOME=/root
ENV USER_HOME=/home/${DBZUSER}
ENV KAFKA_CONNECTOR_DIR=${USER_HOME}/kafka_connector
ENV CONNECT_PORT=8083

# Login management
RUN useradd -m -g 0 ${DBZUSER}
RUN usermod --shell /bin/bash ${DBZUSER}
RUN echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/" >> /etc/environment


# Setup Kafka, we are using it only for the connect, the actual Kafka is running at testrun.kafka
WORKDIR ${USER_HOME}
RUN wget https://downloads.apache.org/kafka/3.5.1/kafka_2.12-3.5.1.tgz
RUN tar -xzvf kafka_2.12-3.5.1.tgz
RUN ln -s kafka_2.12-3.5.1 kafka
RUN chown ${DBZUSER}:root -R kafka/
COPY --chown=${DBZUSER}:root ./kafka_config/connect-distributed.properties ${USER_HOME}/kafka/config/connect-distributed.properties
RUN export CONNECT_PORT=${CONNECT_PORT}
RUN export KAFKA_CONNECTOR_DIR=${KAFKA_CONNECTOR_DIR}
RUN sed -i "s/{{ kafka.kafka }}/testrun.kafka/g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s/{{ kafka.kafka.port }}/9092/g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s/{{ kafka.connect }}/testrun.connect/" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s/{{ kafka.connect.port }}/${CONNECT_PORT}/g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s/{{ kafka.connect.lead }}/testrun.connect/g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s/{{ kafka.connect.lead.port }}/${CONNECT_PORT}/g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s/{{ kafka.connect.lead.protocol }}/http/g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN sed -i "s|{{ kafka_connector_dir }}|${KAFKA_CONNECTOR_DIR}|g" ${USER_HOME}/kafka/config/connect-distributed.properties
RUN rm kafka_2.12-3.5.1.tgz
RUN mkdir logs
RUN chown ${DBZUSER}:root logs


# Setup Debezium
WORKDIR ${USER_HOME}
RUN wget https://repo1.maven.org/maven2/io/debezium/debezium-connector-mysql/2.3.4.Final/debezium-connector-mysql-2.3.4.Final-plugin.tar.gz
RUN mkdir ${KAFKA_CONNECTOR_DIR}
RUN chown ${DBZUSER}:root ${KAFKA_CONNECTOR_DIR}
RUN tar -xzvf debezium-connector-mysql-2.3.4.Final-plugin.tar.gz -C ${KAFKA_CONNECTOR_DIR}/
RUN chown ${DBZUSER}:root ${KAFKA_CONNECTOR_DIR}
COPY --chown=${DBZUSER}:root --chmod=700 ./startup_script.sh ${USER_HOME}/startup_script.sh
RUN export USER_HOME=${USER_HOME}
RUN sed -i "s|{{ USER_HOME }}|${USER_HOME}|g" ${USER_HOME}/startup_script.sh

EXPOSE 8083

WORKDIR ${USER_HOME}

USER ${DBZUSER}

ENTRYPOINT ${USER_HOME}/startup_script.sh
