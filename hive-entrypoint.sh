#!/bin/bash
# =============================================================================
# hive-entrypoint.sh — HiveServer2 startup script
#
# Runs inside the hive-server container. Handles:
#   0. Writing hive-site.xml with credentials from env vars
#   1. Initialising the Hive Metastore schema in PostgreSQL
#   2. Waiting for HDFS to exit Safe Mode
#   3. Creating lab HDFS directories (/user/uitm/...)
#   4. Setting directory permissions
#   5. Starting HiveServer2
#
# Credentials are passed as DB_USER and DB_PASS environment variables
# set in docker-compose.yml from .env — they are never hardcoded here.
# =============================================================================
set -e

echo "=== [0/5] Writing hive-site.xml with credentials from environment ==="
# We write hive-site.xml from this script rather than mounting it read-only,
# because our custom entrypoint bypasses the apache/hive image's own
# HIVE_SITE_CONF_* injection mechanism. Shell variable expansion here gives
# us the same result cleanly, without any YAML heredoc parsing issues.
cat > /opt/hive/conf/hive-site.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:postgresql://postgres:5432/metastore</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>org.postgresql.Driver</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>${DB_USER}</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>${DB_PASS}</value>
  </property>
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://namenode:9000</value>
  </property>
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>hdfs://namenode:9000/user/hive/warehouse</value>
  </property>
  <property>
    <name>hive.server2.enable.doAs</name>
    <value>false</value>
  </property>
  <property>
    <name>hive.support.concurrency</name>
    <value>true</value>
  </property>
  <property>
    <name>hive.txn.manager</name>
    <value>org.apache.hadoop.hive.ql.lockmgr.DbTxnManager</value>
  </property>
  <property>
    <name>hive.compactor.initiator.on</name>
    <value>true</value>
  </property>
  <property>
    <name>hive.compactor.worker.threads</name>
    <value>1</value>
  </property>
  <property>
    <name>hive.execution.engine</name>
    <value>mr</value>
  </property>
  <property>
    <name>hive.server2.thrift.port</name>
    <value>10000</value>
  </property>
  <property>
    <name>hive.server2.thrift.bind.host</name>
    <value>0.0.0.0</value>
  </property>
  <property>
    <name>hive.resultset.use.unique.column.names</name>
    <value>false</value>
  </property>
  <property>
    <name>hive.metastore.schema.verification</name>
    <value>true</value>
  </property>
</configuration>
EOF
echo "    hive-site.xml written — metastore user: ${DB_USER}"

echo "=== [1/5] Initialising Hive Metastore schema in PostgreSQL ==="
/opt/hive/bin/schematool -dbType postgres -initOrUpgradeSchema --verbose

echo "=== [2/5] Waiting for HDFS to exit Safe Mode ==="
until hdfs dfsadmin -fs hdfs://namenode:9000 -safemode wait; do
  echo "    ... retrying in 5s"; sleep 5
done

echo "=== [3/5] Creating lab HDFS directories ==="
HADOOP_USER_NAME=root hdfs dfs -fs hdfs://namenode:9000 \
  -mkdir -p \
    /tmp/hive \
    /user/hive/warehouse \
    /user/uitm/hd_data \
    /user/uitm/data/textdata \
    /user/uitm/data/ratings \
    /user/uitm/data/weblog \
    /user/uitm/data/exercise/wordcount \
    /user/uitm/data/movie_review_output

echo "=== [4/5] Setting directory permissions ==="
HADOOP_USER_NAME=root hdfs dfs -fs hdfs://namenode:9000 \
  -chmod 777 /tmp
HADOOP_USER_NAME=root hdfs dfs -fs hdfs://namenode:9000 \
  -chmod 777 /tmp/hive
HADOOP_USER_NAME=root hdfs dfs -fs hdfs://namenode:9000 \
  -chmod 777 /user/hive/warehouse
HADOOP_USER_NAME=root hdfs dfs -fs hdfs://namenode:9000 \
  -chmod -R 777 /user/uitm

echo "=== [5/5] Starting HiveServer2 ==="
exec /opt/hive/bin/hiveserver2
