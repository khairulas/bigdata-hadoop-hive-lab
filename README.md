# Big Data Lab: Hadoop & Hive on Docker

A fully containerized Big Data environment for teaching Hadoop HDFS and Apache Hive 4.0.

## Prerequisites
* Docker Desktop installed and running.
* 4GB+ RAM allocated to Docker.

## Quick Start

### 1. Start the Cluster
Open your terminal in this folder and run:
```bash
docker-compose up -d
```

2. Wait for Initialization
Wait about 60 seconds for the containers to fully initialize and for HDFS to leave "Safe Mode".

3. Set Permissions (Run once after starting)
Run these commands in your terminal to unlock HDFS and create the necessary folders:

```Bash

docker exec -it namenode hdfs dfs -chmod -R 777 /
docker exec -it namenode hdfs dfs -mkdir -p /user/hive/warehouse
docker exec -it namenode hdfs dfs -chmod -R 777 /user/hive/warehouse
```

4. Connect to Hive
Access the Hive SQL CLI (Beeline) using this command:

```Bash

docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

## 🛠 Advanced: Container Access & Administration

Sometimes you need to go "inside" the servers to run manual commands, fix permissions, or debug issues.

### 1\. How to Enter the Container Shell (Bash)

Use these commands to open a Linux terminal inside the specific container.

  * **To manage HDFS files (NameNode):**
    ```bash
    docker exec -it namenode bash
    ```
  * **To manage Hive logs or configuration:**
    ```bash
    docker exec -it hive-server bash
    ```
  * **To exit the shell:**
    Type `exit` and press Enter.

### 2\. Basic Hadoop Administration Cheat Sheet

Once you are inside the **NameNode** shell (`docker exec -it namenode bash`), you can run these administrative commands:

#### **File System Operations**

| Action | Command |
| :--- | :--- |
| **List files** | `hdfs dfs -ls /` |
| **Create directory** | `hdfs dfs -mkdir -p /user/mydata` |
| **Upload file** | `hdfs dfs -put /local/path/file.csv /hdfs/path/` |
| **Delete file** | `hdfs dfs -rm /path/to/file` |
| **Delete folder** | `hdfs dfs -rm -r /path/to/folder` |
| **Check file content** | `hdfs dfs -cat /path/to/file` |

#### **Permissions & Ownership**

| Action | Command |
| :--- | :--- |
| **Change Permissions** | `hdfs dfs -chmod -R 777 /user/hive` |
| **Change Owner** | `hdfs dfs -chown -R hive:supergroup /user/hive` |

#### **Cluster Health & Maintenance**

| Action | Command |
| :--- | :--- |
| **Check Disk Usage** | `hdfs dfs -du -h /` |
| **Cluster Status** | `hdfs dfsadmin -report` |
| **Check Safe Mode** | `hdfs dfsadmin -safemode get` |
| **Leave Safe Mode** | `hdfs dfsadmin -safemode leave` |
*(Note: If HDFS refuses to write files immediately after startup, it is likely in "Safe Mode". Run the leave command to fix it.)*


## Lab Exercises

### Exercise 1: External Tables

Inside the Beeline console:

```sql
-- 1. Create a raw folder in HDFS
-- (Run in terminal: docker exec -it namenode hdfs dfs -mkdir -p /data/external_lab)
-- (Run in terminal: docker exec -it namenode hdfs dfs -chmod -R 777 /data/external_lab)

-- 2. Create the external table
CREATE EXTERNAL TABLE lab_students (id INT, name STRING)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/data/external_lab';

-- 3. Insert and Select
INSERT INTO lab_students VALUES (500, 'Student A');
SELECT * FROM lab_students;
```
Troubleshooting
Connection Refused? If beeline fails to connect, the server might still be starting. Wait 30 more seconds or run docker logs hive-server to check progress.

Permission Denied? Re-run the commands in Step 3 of the Quick Start to ensure HDFS is writable.

# Hive & Power BI Integration using ODBC

### Step 1: Install the ODBC Driver
Power BI does not speak "Hive" natively; it speaks ODBC. You need to install the official driver.

1. Download the Microsoft Hive ODBC Driver.

   * Go to Microsoft''s official download page (search "Microsoft Hive ODBC Driver").

   * Or use the direct link for the 64-bit version (assuming you are on 64-bit Windows): Download Here.

2. Install the .msi file.

### Step 2: Configure the Connection (ODBC DSN)
We need to create a saved connection setting in Windows.

1. Press Windows Key and type ODBC Data Sources (64-bit). Open it.
   
2. Go to the System DSN tab (so it works for all users).
   
3. Click Add...
   
4. Select Microsoft Hive ODBC Driver and click Finish
   
5. Fill in the Configuration Form:

   * Data Source Name: DockerHive (or any name you want).

   * Host: localhost (or 127.0.0.1).

   * Port: 10000.

   * Database: default.

   * Mechanism: Select User Name (Simple Authentication).

   * User Name: hive (or root).

   * Password: (Leave this empty; our Docker setup uses "Simple" mode which trusts any login).

6. Click "Test".

  * If it says "SUCCESS", you are ready.

  * Note: If it fails, ensure your Docker container is running (docker ps) and HiveServer2 is active.

### Step 3: Connect in Power BI
1. Open Power BI Desktop.

2. Click Get Data -> More...
   
3. Search for ODBC and select it.
   
4. In the dropdown menu, select the DSN you just created (DockerHive).
   
5. Click OK.

6. Navigator Window:

   * You should see HIVE on the left side.

   * Expand it to see default and your other da*tabases (like internal_students or external_students).

   * Select the tables you want and click Load.
