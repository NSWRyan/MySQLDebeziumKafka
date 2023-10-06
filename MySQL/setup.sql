CREATE DATABASE test_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'kafkauser' IDENTIFIED BY 'kafkapass';
GRANT ALL PRIVILEGES ON test_db.* TO 'kafkauser';

-- Debezium setup
CREATE USER 'debezium' IDENTIFIED BY 'dbz';
GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium';

CREATE TABLE IF NOT EXISTS test_db.test_table
(
    id_col1 int NOT NULL AUTO_INCREMENT,
    col2 varchar(255),
    dt_col3 DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_col1)
) engine = innodb; 

INSERT INTO test_db.test_table (col2) VALUES ('A');
INSERT INTO test_db.test_table (col2) VALUES ('B');
INSERT INTO test_db.test_table (col2) VALUES ('C');
