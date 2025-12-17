
# Big Data Lab: Hadoop & Hive on Docker

A fully containerized Big Data environment for teaching Hadoop HDFS, Apache Hive 4.0, MapReduce, and Data Warehousing concepts.

## Prerequisites
* **Docker Desktop** installed and running.
* **4GB+ RAM** allocated to Docker resources.
* **ODBC Driver** (optional, for Power BI integration).


## 📥 Installation

1. **Clone the Repository**
    Open your terminal (PowerShell or CMD) and run:
    ```bash
    git clone https://github.com/khairulas/bigdata-hadoop-hive-lab.git
    ```

2.  **Navigate to the Directory**
    ```bash
    cd bigdata-hadoop-hive-lab
    ```


## 🚀 Quick Start

### 1\. Start the Cluster

Run this command to start the stack:
cd
```bash
docker-compose up -d
```

### 2\. Wait for Initialization

Wait about **60 seconds** for the containers to fully initialize and for HDFS to leave "Safe Mode".

### 3\. Set Permissions (Run once after starting)

Run these commands in your terminal to unlock HDFS and create the necessary folders:

```bash
docker exec -it namenode hdfs dfs -chmod -R 777 /
docker exec -it namenode hdfs dfs -mkdir -p /user/hive/warehouse
docker exec -it namenode hdfs dfs -chmod -R 777 /user/hive/warehouse
```

### 4\. Connect to Hive CLI

Access the Hive SQL CLI (Beeline) using this command:

```bash
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000
```

-----

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

Once inside the **NameNode** shell, you can run these commands:

| Action | Command |
| :--- | :--- |
| **List files** | `hdfs dfs -ls /` |
| **Create directory** | `hdfs dfs -mkdir -p /user/mydata` |
| **Upload file** | `hdfs dfs -put /local/path/file.csv /hdfs/path/` |
| **Delete file** | `hdfs dfs -rm /path/to/file` |
| **Check file content** | `hdfs dfs -cat /path/to/file` |
| **Check Disk Usage** | `hdfs dfs -du -h /` |
| **Check Safe Mode** | `hdfs dfsadmin -safemode get` |
| **Leave Safe Mode** | `hdfs dfsadmin -safemode leave` |

-----

## 🧪 Lab Exercises

### Exercise 1: External Tables (Parquet)

**Objective:** Create an external table manually inside HDFS.

1.  **Create a raw folder in HDFS** (Run in terminal):

    ```bash
    docker exec -it namenode hdfs dfs -mkdir -p /data/external_lab
    docker exec -it namenode hdfs dfs -chmod -R 777 /data/external_lab
    ```

2.  **Create the external table** (Run in Beeline):

    ```sql
    CREATE EXTERNAL TABLE lab_students (id INT, name STRING)
    STORED AS PARQUET
    LOCATION 'hdfs://namenode:9000/data/external_lab';
    ```

3.  **Insert and Select** (Run in Beeline):

    ```sql
    INSERT INTO lab_students VALUES (500, 'Student A');
    SELECT * FROM lab_students;
    ```

### Exercise 2: Data Ingestion and External Tables (CSV)

**Objective:** Practice ETL by loading a raw CSV file from the host machine into HDFS and creating a resilient Hive External Table.

#### Step 1: Ingest Data to HDFS (Terminal Commands)

1.  **Prepare Data:** Ensure `ratings.csv` is in your local `data/` folder.

2.  **Copy file from Host to NameNode Container:**

    ```bash
    docker cp data/ratings.csv namenode:/tmp/ratings.csv
    ```

3.  **Upload file from Container to HDFS:**

    ```bash
    docker exec -it namenode hdfs dfs -mkdir -p /user/data/ratings
    docker exec -it namenode hdfs dfs -put -f /tmp/ratings.csv /user/data/ratings/ratings.csv
    ```

#### Step 2: Create Hive External Table (Beeline)

Run the following SQL in Beeline to map the data:

```sql
USE default; 

CREATE EXTERNAL TABLE IF NOT EXISTS ratings (
    userid INT,
    movieid INT,
    rating DOUBLE,
    ts BIGINT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION 'hdfs://namenode:9000/user/data/ratings'
TBLPROPERTIES ("skip.header.line.count"="1");
```

#### Step 3: Verify Data

```sql
SELECT * FROM ratings LIMIT 10;
SELECT AVG(rating), COUNT(movieid) FROM ratings;
```

### Exercise 3: MapReduce Data Analysis (WordCount)

**Objective:** Execute a classic MapReduce job using YARN to analyze text data. We will count the frequency of every word in a text file.

#### Step 1: Create Input Data

Run these commands in your **local terminal** to generate a simple text file inside the NameNode:

```bash
# 1. Enter the NameNode
docker exec -it namenode bash

# 2. Create a dummy text file
echo "Hadoop is great" > input.txt
echo "Hive is SQL on Hadoop" >> input.txt
echo "Big Data is the future" >> input.txt
echo "Hadoop uses MapReduce" >> input.txt

# 3. Create an input directory in HDFS
hdfs dfs -mkdir -p /user/mapreduce/input

# 4. Upload the file to HDFS
hdfs dfs -put input.txt /user/mapreduce/input/
```

#### Step 2: Run the MapReduce Job

We will use the built-in Hadoop example JAR to run the `wordcount` program. We use a dynamic command (`grep -v sources`) to automatically find the correct executable JAR file.

```bash
# Run this inside the NameNode shell
yarn jar /opt/hadoop-3.2.1/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.2.1.jar wordcount /user/mapreduce/input /user/mapreduce/output
```

*Note: If the output directory `/user/mapreduce/output` already exists, the job will fail. You must delete it first using `hdfs dfs -rm -r /user/mapreduce/output`.*

#### Step 3: View Results

Read the output file generated by the Reducer:

```bash
hdfs dfs -cat /user/mapreduce/output/part-r-00000
```

**Expected Output:**

```
Big     1
Data    1
Hadoop  3
Hive    1
MapReduce 1
SQL     1
...
```

-----

## 📊 Integration: Hive & Power BI

### Step 1: Install the ODBC Driver

1.  Download the **Microsoft Hive ODBC Driver** (64-bit) from the official Microsoft website.
2.  Install the `.msi` file.

### Step 2: Configure ODBC Data Source

1.  Open Windows Search and run **ODBC Data Sources (64-bit)**.
2.  Go to the **System DSN** tab and click **Add...**
3.  Select **Microsoft Hive ODBC Driver** and click Finish.
4.  Configure as follows:
      * **Data Source Name:** `DockerHive`
      * **Host:** `localhost`
      * **Port:** `10000`
      * **Database:** `default`
      * **Mechanism:** `User Name`
      * **User Name:** `hive`
      * **Password:** *(Leave Empty)*
5.  Click **Test**. If it says "SUCCESS", you are ready.

### Step 3: Connect in Power BI

1.  Open **Power BI Desktop**.
2.  Click **Get Data -\> More... -\> ODBC**.
3.  Select `DockerHive` from the dropdown.
4.  In the Navigator, expand **HIVE** to see your tables (`lab_students`, `ratings`).
5.  Select tables and click **Load**.

-----

## ❓ Troubleshooting

  * **Connection Refused?** If Beeline fails to connect, the server might still be starting. Wait 30 more seconds or run `docker logs hive-server` to check progress.

  * **Permission Denied?** Re-run the commands in "Step 3: Set Permissions" of the Quick Start to ensure HDFS is writable.

<!-- end list -->
