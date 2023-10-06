FROM ubuntu:mantic-20230912

RUN apt-get update && \
    apt-get -y install  libssl-dev \
                    libbz2-dev \
                    libffi-dev \            
                    openssh-server \ 
                    openssh-client \
                    cron \
                    openjdk-17-jdk \
                    zookeeperd \
                    git && \
    apt-get clean all

# Env setup
ENV KAFKAUSER=kafkauser
ENV ZOOKEEPERUSER=zookeeper
ENV ROOT_HOME=/root
ENV USER_HOME=/home/${KAFKAUSER}

# Login management
RUN useradd -m -g 0 ${KAFKAUSER}
RUN usermod --shell /bin/bash ${KAFKAUSER}
RUN usermod --shell /bin/bash ${ZOOKEEPERUSER}
RUN echo "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/" >> /etc/environment

USER ${KAFKAUSER}

# Setup Kafka
WORKDIR ${USER_HOME}
RUN wget https://downloads.apache.org/kafka/3.5.1/kafka_2.12-3.5.1.tgz
RUN tar -xzvf kafka_2.12-3.5.1.tgz
RUN ln -s kafka_2.12-3.5.1 kafka
RUN chown ${KAFKAUSER}:root -R kafka
COPY --chown=${KAFKAUSER}:root ./kafka_config/server.properties ${USER_HOME}/kafka/config/server.properties
RUN sed -i "s/{{ kafka.kafka }}/testrun.kafka/g" ${USER_HOME}/kafka/config/server.properties
RUN rm kafka_2.12-3.5.1.tgz
RUN mkdir logs
RUN chown ${KAFKAUSER}:root logs

EXPOSE 9092

COPY --chown=${KAFKAUSER}:root --chmod=700 ./startup_script.sh ${USER_HOME}/startup_script.sh
RUN export USER_HOME=${USER_HOME}
RUN sed -i "s|{{ USER_HOME }}|${USER_HOME}|g" ${USER_HOME}/startup_script.sh

# CMD ["/usr/sbin/init"]

ENTRYPOINT ${USER_HOME}/startup_script.sh
