# Big Data Lab: Hadoop & Hive on Docker

> **DSC650 Lab Module — FSKM, UiTM Cawangan Perlis**  
> A fully containerised Big Data environment for teaching Hadoop HDFS, Apache Hive 4.0, MapReduce, and Data Warehousing concepts.

---

## What's in This Stack

| Container | Image | Role |
|---|---|---|
| `namenode` | bde2020/hadoop-namenode:2.0.0-hadoop3.2.1-java8 | HDFS metadata server |
| `datanode` | bde2020/hadoop-datanode:2.0.0-hadoop3.2.1-java8 | HDFS block storage |
| `resourcemanager` | bde2020/hadoop-resourcemanager:2.0.0-hadoop3.2.1-java8 | YARN job scheduler |
| `nodemanager` | bde2020/hadoop-nodemanager:2.0.0-hadoop3.2.1-java8 | YARN task executor |
| `hive-server` | apache/hive:4.0.0 (custom) | HiveServer2 + schematool |
| `postgres` | postgres:13 | Hive Metastore backend |
| `hue` | gethue/hue:4.11.0 | Web UI for HDFS & Hive |
| `edge-node` | bde2020/hadoop-base:2.0.0-hadoop3.2.1-java8 | **Student workspace** |

> **Key architectural principle:** Students do all CLI work from `edge-node`, not from `namenode` or `resourcemanager`. See [Why the Edge Node?](#️-why-the-edge-node) below.

---

## Prerequisites

- **Docker Desktop** installed and running (WSL 2 backend on Windows)
- **8 GB RAM** minimum allocated to Docker (Settings → Resources)
- **Git** for cloning the repository
- **ODBC Driver** (optional, for Power BI integration in Lab 5)

---

## 📥 Installation

### 1. Clone the Repository

```powershell
git clone https://github.com/khairulas/bigdata-hadoop-hive-lab.git
cd bigdata-hadoop-hive-lab
```

### 2. Download the PostgreSQL JDBC Driver

The Hive image requires the PostgreSQL JDBC driver to connect to its metastore. Download it once before the first build:

```powershell
# PowerShell
New-Item -ItemType Directory -Force -Path lib
Invoke-WebRequest -Uri "https://jdbc.postgresql.org/download/postgresql-42.7.4.jar" `
  -OutFile "lib\postgresql-42.7.4.jar"
```

### 3. Configure Environment Variables

Copy the example environment file and review the defaults:

```powershell
copy .env.example .env
```

The `.env` file contains all credentials and image versions. The defaults work out of the box for a local lab — no changes are required unless you want a different password.

```env
POSTGRES_USER=hive
POSTGRES_PASSWORD=hive_lab_2024
POSTGRES_DB=metastore
HUE_IMAGE=gethue/hue:4.11.0
HADOOP_IMAGE_TAG=2.0.0-hadoop3.2.1-java8
HADOOP_HEAPSIZE=2048
CLUSTER_NAME=bigdata-lab
```

> ⚠️ `.env` is listed in `.gitignore` and will never be committed. Do not hardcode credentials anywhere else.

---

## 🚀 Quick Start

### Start the Cluster

```powershell
docker-compose up -d
```

The first run builds the custom `hive-server` image (copies the JDBC driver in). Subsequent starts use the cached image and are much faster.

### Wait for Initialisation

Allow **90–120 seconds** for all services to become healthy. The `hive-server` runs `schematool` to initialise the Postgres metastore schema and creates all required HDFS directories automatically. You do not need to run any manual HDFS permission commands.

Monitor progress:

```powershell
docker-compose ps          # check container health status
docker logs hive-server    # watch hive-server startup steps
```

You should see the hive-server log progress through five steps:

```
=== [0/5] Writing hive-site.xml with credentials from environment ===
=== [1/5] Initialising Hive Metastore schema in PostgreSQL ===
=== [2/5] Waiting for HDFS to exit Safe Mode ===
=== [3/5] Creating lab HDFS directories ===
=== [4/5] Setting directory permissions ===
=== [5/5] Starting HiveServer2 ===
```

### Access Points

| Service | URL / Command |
|---|---|
| HDFS NameNode UI | http://localhost:9870 |
| YARN Resource Manager UI | http://localhost:8088 |
| HiveServer2 Web UI | http://localhost:10002 |
| Hue Web UI | http://localhost:8888 |
| Beeline (Hive CLI) | `docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -p hive_lab_2024` |

---

## 🖥️ Why the Edge Node?

> **All student CLI work runs inside `edge-node` — not `namenode`, not `resourcemanager`.**

The `namenode` is the single most critical component in a Hadoop cluster. It holds the entire HDFS filesystem namespace in memory. If a student accidentally runs a destructive command inside it, or corrupts the namespace, the entire lab cluster becomes unrecoverable without a full restart and data loss.

In real Hadoop deployments, operators treat the NameNode as an untouchable control-plane server. Data engineers connect to a **gateway node** (also called an edge node) that has the Hadoop client tools installed and communicates with the cluster over the network — which is exactly what `edge-node` provides here.

The `edge-node` container has:
- Full Hadoop client: `hdfs dfs`, `yarn jar`, `javac`, `hadoop classpath`
- Beeline for Hive SQL
- Your lab datasets at `/home/student/training/` (read-only)
- Your personal writable workspace at `/home/student/mydata/`

### Student Entry Point (All Labs)

```powershell
docker exec -it edge-node bash
```

That's the only container students need to exec into for Labs 1–4. For Lab 5, Terminal 2 connects directly to hive-server via Beeline.

---

## 📂 Student Workspace Layout

Inside `edge-node`:

```
/home/student/
├── training/          ← read-only lab datasets (accounts.csv, movies.txt, etc.)
│   └── data/
│       ├── accounts.csv
│       ├── movies.txt
│       ├── employees.json
│       ├── ratings.csv
│       └── logs/
│           └── 2014-01-12.log
└── mydata/            ← your writable workspace
    └── exercises/     ← write Java source code here
```

**Workflow for putting data into HDFS:**

```bash
# Inside edge-node
cp /home/student/training/data/accounts.csv /home/student/mydata/
hdfs dfs -put /home/student/mydata/accounts.csv /user/uitm/hd_data/
```

**Pre-created HDFS directories** (created automatically at startup):

```
/user/hive/warehouse          ← Hive managed tables
/user/uitm/hd_data            ← Lab 1 upload exercises
/user/uitm/data/textdata      ← Lab 2 & 3 text data
/user/uitm/data/ratings       ← Lab 5 Hive external tables
/user/uitm/data/weblog        ← Lab 4 log file analysis
/user/uitm/data/exercise/     ← MapReduce job output
/user/uitm/data/movie_review_output
/user/uitm/staging            ← temporary staging for LOAD DATA INPATH
```

---

## 🧪 Lab Exercises Overview

| Lab | Title | Primary Containers |
|---|---|---|
| Lab 1 | Apache Hadoop — Local Files & HDFS | `edge-node` |
| Lab 2 | Executing a MapReduce Job (WordCount) | `edge-node` → YARN |
| Lab 3 | HDFS Administration (Block Size & Replication) | Host + `edge-node` |
| Lab 4 | Log File Analysis (Custom MapReduce) | `edge-node` → YARN |
| Lab 5 | Apache Hive (SQL, Partitioning, Avro, Parquet) | `edge-node` + `hive-server` |

The full lab module document is in the `labs/` folder.

### Lab 1 — HDFS Basics

```bash
# Enter the student workspace
docker exec -it edge-node bash

# Navigate to lab datasets
cd /home/student/training/data
ls -l

# Upload a file to HDFS
hdfs dfs -mkdir -p /user/uitm/hd_data
hdfs dfs -put accounts.csv /user/uitm/hd_data/accounts.csv
hdfs dfs -ls /user/uitm/hd_data
```

### Lab 2 — MapReduce (WordCount)

```bash
# Inside edge-node — compile and submit
mkdir -p /home/student/mydata/exercises/wordcount/src/solution
cd /home/student/mydata/exercises/wordcount/src

javac -d . -classpath $(hadoop classpath) solution/WordCount.java
jar cvf wc.jar solution/*.class

yarn jar wc.jar solution.WordCount \
  /user/uitm/data/textdata \
  /user/uitm/data/exercise/wordcount

hdfs dfs -cat /user/uitm/data/exercise/wordcount/part-r-00000 | head -n 20
```

### Lab 3 — HDFS Administration

```powershell
# On your HOST machine — edit block size config
docker cp namenode:/opt/hadoop-3.2.1/etc/hadoop/hdfs-site.xml ./hdfs-site.xml
# (edit hdfs-site.xml — add dfs.blocksize=268435456)
docker cp ./hdfs-site.xml edge-node:/opt/hadoop-3.2.1/etc/hadoop/hdfs-site.xml
docker restart namenode datanode edge-node
```

```bash
# Back inside edge-node — test new block size
docker exec -it edge-node bash
hdfs dfs -put /home/student/training/data/movies.txt \
  /user/uitm/data/textdata/movies_256mb.txt
```

Verify at http://localhost:9870 → Utilities → Browse the file system.

### Lab 4 — Log File Analysis

```bash
# Inside edge-node
docker exec -it edge-node bash

hdfs dfs -put /home/student/training/data/logs/2014-01-12.log \
  /user/uitm/data/weblog/

yarn jar logfile.jar solution.LogFileAnalysis \
  /user/uitm/data/weblog/2014-01-12.log \
  /user/uitm/data/logfileoutput

hdfs dfs -cat /user/uitm/data/logfileoutput/part-r-00000 | head -n 20
```

Monitor jobs at http://localhost:8088.

### Lab 5 — Apache Hive (Two-Terminal Setup)

Open two PowerShell terminals side by side:

**Terminal 1 — HDFS Admin (edge-node):**
```powershell
docker exec -it edge-node bash
```

**Terminal 2 — Hive SQL Analyst (Beeline):**
```powershell
docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -p hive_lab_2024
```

#### Loading Data into Hive — Important Architecture Note

> ⚠️ **`LOAD DATA LOCAL` does not work in this setup.**  
> `LOCAL` reads from the filesystem of the **hive-server** container, which does not have the training data mounted. Always load data via HDFS from `edge-node` (Terminal 1).

**External Table — push file to HDFS, no LOAD needed:**

The `LOCATION` clause in `CREATE EXTERNAL TABLE` points Hive directly at an HDFS directory. Any file placed there is immediately queryable — no `LOAD DATA` command is required.

```sql
-- Terminal 2: create the external table
CREATE EXTERNAL TABLE ratings (
  userid  int,
  movieid int,
  rating  int,
  tstamp  string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/user/uitm/data/ratings';
```

```bash
# Terminal 1 (edge-node): push the file to the LOCATION path
hdfs dfs -put /home/student/training/data/ratings.csv /user/uitm/data/ratings/
hdfs dfs -ls /user/uitm/data/ratings/
```

```sql
-- Terminal 2: data is immediately available
SELECT * FROM ratings LIMIT 10;
```

**Managed Table — upload to staging first, then LOAD from HDFS:**

```bash
# Terminal 1 (edge-node): upload to a staging directory
hdfs dfs -mkdir -p /user/uitm/staging
hdfs dfs -put /home/student/training/data/ratings.csv /user/uitm/staging/ratings.csv
```

```sql
-- Terminal 2: create and load the managed table (no LOCAL keyword)
CREATE TABLE ratings_managed (
  userid  int,
  movieid int,
  rating  int,
  tstamp  string
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ',';

LOAD DATA INPATH '/user/uitm/staging/ratings.csv' INTO TABLE ratings_managed;
SELECT * FROM ratings_managed LIMIT 10;
```

---

## 🛠 Container Reference

### Useful Commands

```powershell
# View all container statuses
docker-compose ps

# Start / stop the whole cluster
docker-compose up -d
docker-compose down

# Tear down and wipe all data volumes (full reset)
docker-compose down -v

# View logs for a specific container
docker logs hive-server
docker logs namenode

# Follow live logs
docker logs -f hive-server
```

### HDFS Cheat Sheet (run inside edge-node)

| Action | Command |
|---|---|
| List files | `hdfs dfs -ls /user/uitm` |
| Create directory | `hdfs dfs -mkdir -p /user/uitm/mydir` |
| Upload file | `hdfs dfs -put /local/file.csv /user/uitm/mydir/` |
| Download file | `hdfs dfs -get /user/uitm/file.csv /home/student/mydata/` |
| Delete file | `hdfs dfs -rm /user/uitm/file.csv` |
| Delete directory | `hdfs dfs -rm -r /user/uitm/mydir` |
| View file contents | `hdfs dfs -cat /user/uitm/file.csv \| head` |
| Check disk usage | `hdfs dfs -du -h /user/uitm` |
| Check Safe Mode | `hdfs dfsadmin -fs hdfs://namenode:9000 -safemode get` |

### Container Access Reference

| Purpose | Command |
|---|---|
| **Student lab work (Labs 1–4)** | `docker exec -it edge-node bash` |
| Hive SQL (Lab 5) | `docker exec -it hive-server beeline -u jdbc:hive2://localhost:10000 -n hive -p hive_lab_2024` |
| Hue Web UI (Lab 5) | http://localhost:8888 |
| Admin — copy config files | `docker cp namenode:/opt/hadoop-3.2.1/etc/hadoop/hdfs-site.xml ./` |
| ❌ Do NOT use | `docker exec -it namenode bash` ← control plane only |
| ❌ Do NOT use | `docker exec -it resourcemanager bash` ← control plane only |

---

## 📊 Power BI Integration (Lab 5)

### Step 1: Install the ODBC Driver

Download and install the **Microsoft Hive ODBC Driver (64-bit)** from the Microsoft website.

### Step 2: Configure ODBC Data Source

1. Open **ODBC Data Sources (64-bit)** from Windows search.
2. Go to **System DSN** → **Add** → **Microsoft Hive ODBC Driver**.
3. Configure:
   - **Data Source Name:** `DockerHive`
   - **Host:** `localhost`
   - **Port:** `10000`
   - **Database:** `default`
   - **Mechanism:** `User Name`
   - **User Name:** `hive`
   - **Password:** `hive_lab_2024`
4. Click **Test** — you should see `SUCCESS`.

### Step 3: Connect in Power BI

1. Open **Power BI Desktop** → **Get Data** → **ODBC**.
2. Select `DockerHive`.
3. In the Navigator, expand **HIVE** to see your tables.
4. Select tables and click **Load**.

---

## 🗂 Repository Structure

```
bigdata-hadoop-hive-lab/
├── .env                      ← secrets & image versions (not committed)
├── .env.example              ← template for .env
├── .gitattributes            ← enforces LF line endings for .sh files
├── .gitignore
├── docker-compose.yml        ← full 8-service stack definition
├── Dockerfile.hive           ← custom hive-server image (adds JDBC driver)
├── hive-entrypoint.sh        ← startup script: writes hive-site.xml, schematool, HDFS dirs
├── hive-site.xml             ← static Hive config (no credentials)
├── core-site.xml             ← Hadoop core config (proxy-user, WebHDFS)
├── hue.ini                   ← Hue web UI configuration
├── init-hive-db.sql          ← idempotent: creates metastore + hue databases in Postgres
├── lib/
│   └── postgresql-42.7.4.jar ← JDBC driver (download via setup instructions)
├── training/
│   └── data/                 ← lab datasets (mounted read-only into edge-node)
│       ├── accounts.csv
│       ├── movies.txt
│       ├── employees.json
│       ├── ratings.csv
│       └── logs/
│           └── 2014-01-12.log
└── labs/
    └── DSC650_Lab_Module_Lab1-5.docx
```

---

## ❓ Troubleshooting

**`hive-server` shows Error or unhealthy:**
```powershell
docker logs hive-server 2>&1 | Select-Object -Last 50
```
Most commonly caused by Postgres not being ready. The entrypoint retries automatically — wait 60 seconds and check again.

**`HADOOP_HOME` variable warnings on startup:**
These are harmless warnings from Docker Compose trying to expand `$HADOOP_HOME` on your Windows host. The variable is correctly set inside the containers at runtime.

**HDFS Safe Mode errors:**
```bash
# Inside edge-node — wait for safe mode to clear automatically, or force-leave:
hdfs dfsadmin -fs hdfs://namenode:9000 -safemode leave
```

**Beeline connection refused:**
HiveServer2 may still be initialising. Wait 90 seconds from first `docker-compose up`, then retry. Check `docker logs hive-server` to confirm step `[5/5] Starting HiveServer2` has completed.

**Hue shows "database does not exist" on first run:**
This is prevented by the updated `init-hive-db.sql` which creates both the `metastore` and `hue` databases idempotently. If you cloned before this fix, do a full reset:
```powershell
docker-compose down -v
docker-compose up -d
```

**Shell script errors (`$'\r': command not found`) inside containers:**
Caused by Windows CRLF line endings in `.sh` files. The repo includes a `.gitattributes` file that enforces LF on clone. If you edited scripts on Windows and see this error, fix with PowerShell:
```powershell
(Get-Content .\hive-entrypoint.sh -Raw) -replace "`r`n", "`n" |
  Set-Content .\hive-entrypoint.sh -NoNewline
```
Then rebuild: `docker-compose up -d --build hive-server`

**Full reset (wipe all data and start fresh):**
```powershell
docker-compose down -v
docker-compose up -d
```

**Docker Desktop Linux engine not found:**
Open Docker Desktop from the Start menu and wait for it to fully start. If it shows an error, right-click the tray icon → Restart Docker Desktop. Then retry `docker-compose up -d`.

---

## Architecture Notes

- **Credentials** are stored only in `.env` and injected into containers at runtime. No passwords exist in any XML or YAML file.
- **hive-site.xml** is written dynamically by `hive-entrypoint.sh` at container startup using environment variables — this bypasses a Hive 4.0 limitation where `${env.X}` XML substitution does not work when a custom entrypoint is used.
- **init-hive-db.sql** uses idempotent `IF NOT EXISTS` guards for both the role and both databases — safe to re-run and safe on fresh installs with empty volumes.
- **`LOAD DATA LOCAL` is unsupported** in this architecture. The training datasets live on `edge-node`; the Hive engine runs in `hive-server`. Always use `hdfs dfs -put` from `edge-node` to stage files, then `LOAD DATA INPATH` (without `LOCAL`) or rely on `LOCATION` for external tables.
- **HDFS permissions** are scoped to `/user/uitm/` and `/user/hive/warehouse` only — no `chmod 777 /` on the root.
- **Image versions** are pinned in `.env` to prevent unexpected breakage from upstream updates.
- **Named Docker volumes** (`namenode_data`, `datanode_data`, `postgres_data`, `hive_home`, `student_work`) persist data across container restarts. Use `docker-compose down -v` only when you want a complete reset.
- **Line endings** — `.gitattributes` enforces `eol=lf` for all `.sh` files, preventing Windows from re-introducing CRLF on clone or checkout.