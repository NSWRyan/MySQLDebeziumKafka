# Explanation
The goal of this tutorial is to get the system to capture data change in the sample MySQL table.

There is this tutorial from debezium using ready to use container. But that is not fun (in my opinion).

https://github.com/debezium/debezium-examples/blob/main/tutorial/docker-compose-mysql.yaml

So here we go, lets learn how it works by doing the setup from scratch.

## Kafka
* This is the main Kafka node that will store the messages.
* I did not use the Kafka docker image for this because I want to learn to set up Kafka directly on a server.
    * The setup is defined in the Dockerfile.

## MySQL
* This is the test DB.
* In the MySQL directory, we have the init SQLs.

## Kafdrop
* Kafdrop's purpose is to make monitoring and managing Kafka easier (it has a web ui!).
* I just use a container for this.
* You may skip this one if you prefer to use command line with Kafka or build your own application.

## kafka-connect
* This is a tool for submitting the data to Kafka.
* In this example, we are using it to get the data from MySQL to Kafka.
* A new job is submitted via curl

## Debezium
* A change data capture (CDC) tool built upon Kafka connect API that sends any change to the target table to Kafka.
* This is only a jar library file that will be loaded by kafka-connect.

## Connecting the dots.
* The overall structure of the system is as follow.
    * MySQL > Debezium/Kafka connect > Kafka > your application.

# Steps:
1. Run docker-compose
    ```
    docker-compose up -d --build
    ```
2. Confirm that all of the containers are running.
    ```
    docker ps

    # Check Kafdrop in the web
    http://localhost:9000/

    # Check Kafka connect
    curl localhost:8083
    ```
3. Submit a job
    ```
    $ curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @dbz_task.json
    ```
4. Modify the data in MySQL.
    ```
    docker exec -it testrun.mysql mysql -u root -h localhost -P 3306 -p
    # insert root pasword here. Hint: check mysql part in docker-compose.yml. Or run docker inspect <container_name_here>. 
    insert into test_db.test_table (col2) values ('D');
    ```
5. Check in Kafdrop for the value.
    ```
    http://localhost:9000/topic/test_mysql_db.test_db.test_table/messages?partition=0&offset=0&count=100&keyFormat=DEFAULT&format=DEFAULT

    Ouput:
    {
    "before": null,
    "after": {
        "id_col1": 4,
        "col2": "D",
        "dt_col3": 1696601203000
    },
    "source": {
        "version": "2.3.4.Final",
        "connector": "mysql",
        "name": "test_mysql_db",
        "ts_ms": 1696568803000,
        "snapshot": "false",
        "db": "test_db",
        "sequence": null,
        "table": "test_table",
        "server_id": 1,
        "gtid": null,
        "file": "mysql-bin.000003",
        "pos": 456,
        "row": 0,
        "thread": 12,
        "query": null
    },
    "op": "c",
    "ts_ms": 1696568803227,
    "transaction": null
    }
    ```


# Kafka-connect helpful commands
* Adding a connector.
    * ```curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @dbz_task.json```
* Checking connectors.
    * ```curl -i -X GET localhost:8083/connectors/```
* Getting a connector config.
    * ```curl -i -X GET localhost:8083/connectors/test_table-connector/```
* Getting a connector status.
    * ```curl -i -X GET localhost:8083/connectors/test_table-connector/status```
* Pausing a connector status.
    * ```curl -i -X PUT localhost:8083/connectors/test_table-connector/pause```
* Deleting a connectors.
    * ```curl -i -X DELETE localhost:8083/connectors/test_table-connector```
* Stopping docker containers in this tutorial.
    * ```docker stop $(docker container ls -a | grep 'testrun' | awk -F ' ' '{ print $1 }')```
* Deleting docker containers in this tutorial.
    * ```docker rm $(docker container ls -a | grep 'testrun' | awk -F ' ' '{ print $1 }')```
* Reset a connector offset to the beginning.
    * First, pause the connector.
    * ```docker exec -it testrun.kafka kafka/bin/kafka-console-producer.sh --broker-list testrun.kafka:9092 --property parse.key=true --property key.separator="&" --topic connect-offsets```
    * Then insert an empty value. ```["test_table-connector",{"server":"test_mysql_db"}]&```
    * Finally, resume the connector.

# Kafka-connect config explanation
* ```"key.converter.schemas.enable":"false"```
    * This lines are to disable schema in the key. The key will be the primary key.
* ```"value.converter.schemas.enable":"false"```
    * This lines are to disable schema in the value.
* ```"table.include.list": "test_db.test_table",```
    * Only track tables in this list.

# Setup/configuration notes
* Listeners in server.properties cannot be localhost/127.0.0.1.
    * For some reason, if it is localhost, then Kafka can only be accessed from localhost.
* Some systemd services exist but are not used.
    * systemd requires priviledged options in the docker-compose.yml.

# References
* https://hevodata.com/blog/how-to-install-kafka-on-ubuntu/
* https://github.com/obsidiandynamics/kafdrop/blob/master/docker-compose/kafka-kafdrop/docker-compose.yaml
* https://debezium.io/documentation/reference/stable/tutorial.html#registering-connector-monitor-inventory-database
* https://github.com/thmshmm/confluent-systemd/blob/master/src/kafka-connect.service
* https://github.com/debezium/container-images/blob/main/examples/mysql/2.5/inventory.sql
* https://stackoverflow.com/questions/43004305/reset-the-jdbc-kafka-connector-to-start-pulling-rows-from-the-beginning-of-time
* https://stackoverflow.com/questions/62072977/whats-default-password-in-docker-container-mysql-server-when-you-dont-set-one
