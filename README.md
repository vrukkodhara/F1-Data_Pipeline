# 🏎️ Formula 1 Data Pipeline

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![PySpark](https://img.shields.io/badge/Apache_Spark-E25A1C?style=for-the-badge&logo=apache-spark&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Data Source](#data-source)
- [Tech Stack](#tech-stack)
- [Data Pipeline Layers](#data-pipeline-layers)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
- [Pipeline Execution](#pipeline-execution)
- [Data Schema](#data-schema)
- [Features](#features)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project implements an end-to-end **ETL (Extract, Transform, Load) data pipeline** for Formula 1 racing data using modern cloud-native technologies. The pipeline extracts historical F1 race data from the Ergast Developer API, processes it using Apache Spark on Databricks, and stores it in a multi-layered data lake architecture on Azure Blob Storage.

### Key Objectives
- **Scalable Data Ingestion**: Automated extraction of F1 historical data
- **Efficient Processing**: Distributed data processing using PySpark
- **Data Quality**: Implementing data validation and cleansing
- **Analytics-Ready**: Structured data optimized for downstream analytics and reporting
- **Medallion Architecture**: Implementation of Bronze → Silver → Gold data layers

## 🏗️ Architecture

### High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          F1 DATA PIPELINE                                │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│   Data Source    │
│                  │
│  Ergast F1 API   │
│  (HTTP/JSON)     │
└────────┬─────────┘
         │
         │ Extract
         ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        AZURE DATABRICKS                                  │
│  ┌───────────────────────────────────────────────────────────────┐     │
│  │                    PySpark Notebooks                           │     │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │     │
│  │  │   Ingestion  │  │Transformation│  │  Aggregation │        │     │
│  │  │   Notebook   │→ │   Notebook   │→ │   Notebook   │        │     │
│  │  └──────────────┘  └──────────────┘  └──────────────┘        │     │
│  └───────────────────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────────────────┘
         │                      │                      │
         │ Write                │ Write                │ Write
         ▼                      ▼                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                    AZURE BLOB STORAGE (Data Lake)                        │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │ BRONZE LAYER │ ──→ │ SILVER LAYER │ ──→ │  GOLD LAYER  │            │
│  │              │     │              │     │              │            │
│  │  Raw Data    │     │  Cleansed &  │     │  Aggregated  │            │
│  │  (JSON/CSV)  │     │  Validated   │     │  & Business  │            │
│  │              │     │    (Parquet) │     │    Ready     │            │
│  │              │     │              │     │   (Delta)    │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
└─────────────────────────────────────────────────────────────────────────┘
         │                      │                      │
         │                      │                      │
         └──────────────────────┴──────────────────────┘
                                │
                                ▼
                    ┌───────────────────────┐
                    │  Analytics & Reporting│
                    │  - Power BI           │
                    │  - Tableau            │
                    │  - Custom Dashboards  │
                    └───────────────────────┘
```

### Detailed Data Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      MEDALLION ARCHITECTURE                              │
└─────────────────────────────────────────────────────────────────────────┘

 ┌─────────────────────────────────────────────────────────────────────┐
 │ BRONZE LAYER (Raw/Landing Zone)                                     │
 ├─────────────────────────────────────────────────────────────────────┤
 │ Purpose: Store raw, unprocessed data exactly as received            │
 │                                                                       │
 │ Data Characteristics:                                                │
 │ ✓ Raw JSON/CSV format from API                                      │
 │ ✓ No transformations applied                                        │
 │ ✓ Append-only, immutable                                            │
 │ ✓ Includes metadata (ingestion timestamp, source info)              │
 │                                                                       │
 │ Tables:                                                              │
 │ • circuits_raw          • lap_times_raw                             │
 │ • races_raw             • pit_stops_raw                             │
 │ • drivers_raw           • qualifying_raw                            │
 │ • constructors_raw      • sprint_results_raw                        │
 │ • results_raw           • driver_standings_raw                      │
 │                         • constructor_standings_raw                  │
 └─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Cleansing & Validation
                                    ▼
 ┌─────────────────────────────────────────────────────────────────────┐
 │ SILVER LAYER (Curated/Cleaned Zone)                                 │
 ├─────────────────────────────────────────────────────────────────────┤
 │ Purpose: Validated, cleaned, and conformed data                     │
 │                                                                       │
 │ Data Characteristics:                                                │
 │ ✓ Data quality checks applied                                       │
 │ ✓ Standardized formats and naming conventions                       │
 │ ✓ Duplicate records removed                                         │
 │ ✓ Missing values handled                                            │
 │ ✓ Data type corrections                                             │
 │ ✓ Stored in Parquet format for efficiency                           │
 │                                                                       │
 │ Transformations:                                                     │
 │ • Schema enforcement                                                 │
 │ • Column renaming (snake_case)                                      │
 │ • Date/time parsing and standardization                             │
 │ • NULL handling                                                      │
 │ • Referential integrity checks                                      │
 └─────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ Business Logic & Aggregations
                                    ▼
 ┌─────────────────────────────────────────────────────────────────────┐
 │ GOLD LAYER (Business/Consumption Zone)                              │
 ├─────────────────────────────────────────────────────────────────────┤
 │ Purpose: Analytics-ready, aggregated datasets                       │
 │                                                                       │
 │ Data Characteristics:                                                │
 │ ✓ Star/Snowflake schema design                                      │
 │ ✓ Denormalized for query performance                                │
 │ ✓ Business metrics pre-calculated                                   │
 │ ✓ Optimized for BI tools                                            │
 │ ✓ Delta Lake format (ACID transactions)                             │
 │                                                                       │
 │ Datasets:                                                            │
 │ • race_results_fact                                                 │
 │ • driver_performance_metrics                                        │
 │ • constructor_championship_summary                                  │
 │ • race_analysis_dim                                                 │
 │ • season_statistics                                                 │
 └─────────────────────────────────────────────────────────────────────┘
```

## 📊 Data Source

### Ergast Developer API

The **Ergast Developer API** is a comprehensive REST API providing historical Formula 1 data from the beginning of F1 (1950) to the present.

- **Official Website**: [http://ergast.com/mrd/](http://ergast.com/mrd/)
- **API Documentation**: [http://ergast.com/mrd/](http://ergast.com/mrd/)
- **Data Format**: JSON/XML
- **Update Frequency**: Real-time during race weekends
- **Historical Coverage**: 1950 - Present

#### Available Data Endpoints

```
Base URL: http://ergast.com/api/f1/

Endpoints:
├── /seasons.json              → List of all F1 seasons
├── /circuits.json             → Circuit information
├── /constructors.json         → Constructor/team details
├── /drivers.json              → Driver information
├── /{year}/races.json         → Races in a specific season
├── /{year}/results.json       → Race results
├── /{year}/qualifying.json    → Qualifying results
├── /{year}/standings/drivers.json      → Driver standings
├── /{year}/standings/constructors.json → Constructor standings
├── /laps.json                 → Lap-by-lap timing
└── /pitstops.json            → Pit stop data
```

#### Example API Request
```bash
# Get all races from 2023 season
curl http://ergast.com/api/f1/2023/races.json

# Get race results for a specific race
curl http://ergast.com/api/f1/2023/1/results.json

# Get driver standings for 2023
curl http://ergast.com/api/f1/2023/driverstandings.json
```

#### Sample Response Structure
```json
{
  "MRData": {
    "xmlns": "http://ergast.com/mrd/1.5",
    "series": "f1",
    "limit": "30",
    "offset": "0",
    "total": "1",
    "RaceTable": {
      "season": "2023",
      "Races": [
        {
          "season": "2023",
          "round": "1",
          "raceName": "Bahrain Grand Prix",
          "Circuit": {
            "circuitId": "bahrain",
            "circuitName": "Bahrain International Circuit",
            "Location": {
              "lat": "26.0325",
              "long": "50.5106",
              "locality": "Sakhir",
              "country": "Bahrain"
            }
          },
          "date": "2023-03-05",
          "time": "15:00:00Z"
        }
      ]
    }
  }
}
```

## 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Cloud Platform** | Microsoft Azure | Cloud infrastructure |
| **Storage** | Azure Blob Storage | Data lake storage (Bronze/Silver/Gold layers) |
| **Processing Engine** | Apache Spark (PySpark) | Distributed data processing |
| **Compute** | Azure Databricks | Managed Spark environment |
| **Data Format** | Parquet, Delta Lake | Columnar storage with ACID properties |
| **Language** | Python 3.x | Pipeline development |
| **Version Control** | Git/GitHub | Code versioning |

### Why These Technologies?

**Azure Blob Storage**
- Scalable and cost-effective data lake storage
- Support for hierarchical namespace (Data Lake Gen2)
- Excellent integration with Databricks
- High availability and durability

**Apache Spark (PySpark)**
- Distributed processing for large datasets
- In-memory computation for faster processing
- Rich ecosystem of libraries
- Excellent for ETL workloads

**Databricks**
- Managed Apache Spark platform
- Collaborative notebooks
- Built-in cluster management
- Integrated with Azure services
- Delta Lake support for ACID transactions

**Delta Lake**
- ACID transactions on data lakes
- Time travel capabilities
- Schema enforcement and evolution
- Unified batch and streaming

## 📁 Data Pipeline Layers

### 🥉 Bronze Layer (Raw Zone)

**Purpose**: Stores raw data exactly as ingested from the source

**Characteristics**:
- Data format: JSON/CSV (as received from API)
- No transformations applied
- Complete data lineage
- Append-only operations
- Includes ingestion metadata

**Directory Structure**:
```
bronze/
├── circuits/
│   └── circuits_raw_{timestamp}.json
├── races/
│   └── races_{year}_{timestamp}.json
├── drivers/
│   └── drivers_raw_{timestamp}.json
├── constructors/
│   └── constructors_raw_{timestamp}.json
├── results/
│   └── results_{year}_{round}_{timestamp}.json
├── qualifying/
│   └── qualifying_{year}_{round}_{timestamp}.json
├── lap_times/
│   └── lap_times_{year}_{round}_{timestamp}.json
├── pit_stops/
│   └── pit_stops_{year}_{round}_{timestamp}.json
└── standings/
    ├── driver_standings_{year}_{timestamp}.json
    └── constructor_standings_{year}_{timestamp}.json
```

**Sample PySpark Code**:
```python
# Read raw data from API and write to Bronze layer
from pyspark.sql import SparkSession
from datetime import datetime

# Initialize Spark session
spark = SparkSession.builder.appName("F1-Bronze-Ingestion").getOrCreate()

# Ingest data
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
bronze_path = f"wasbs://bronze@{storage_account}.blob.core.windows.net/circuits/circuits_raw_{timestamp}.json"

# Write raw data
df_raw.write.mode("append").json(bronze_path)
```

### 🥈 Silver Layer (Cleansed Zone)

**Purpose**: Cleaned, validated, and standardized data

**Characteristics**:
- Data format: Parquet (columnar, compressed)
- Schema enforcement
- Data quality checks applied
- Standardized column names
- Optimized for querying

**Transformations Applied**:
1. **Data Cleansing**
   - Remove duplicates
   - Handle missing values
   - Trim whitespaces
   - Fix malformed records

2. **Data Validation**
   - Type casting
   - Date/time parsing
   - Range checks
   - Referential integrity

3. **Standardization**
   - Column naming conventions (snake_case)
   - Consistent date formats (ISO 8601)
   - Unit conversions
   - Code standardization

**Directory Structure**:
```
silver/
├── circuits/
│   └── circuits_cleansed/
├── races/
│   └── races_cleansed/
├── drivers/
│   └── drivers_cleansed/
├── constructors/
│   └── constructors_cleansed/
├── results/
│   └── results_cleansed/
├── qualifying/
│   └── qualifying_cleansed/
└── standings/
    ├── driver_standings_cleansed/
    └── constructor_standings_cleansed/
```

**Sample PySpark Code**:
```python
from pyspark.sql.functions import col, trim, to_date, regexp_replace

# Read from Bronze
df_bronze = spark.read.json("wasbs://bronze@{storage}.blob.core.windows.net/circuits/")

# Apply transformations
df_silver = (df_bronze
    # Remove duplicates
    .dropDuplicates(["circuitId"])
    
    # Standardize column names
    .withColumnRenamed("circuitId", "circuit_id")
    .withColumnRenamed("circuitName", "circuit_name")
    
    # Clean data
    .withColumn("circuit_name", trim(col("circuit_name")))
    
    # Handle nulls
    .na.fill({"locality": "Unknown", "country": "Unknown"})
    
    # Type casting
    .withColumn("latitude", col("lat").cast("double"))
    .withColumn("longitude", col("long").cast("double"))
)

# Write to Silver (Parquet)
silver_path = "wasbs://silver@{storage}.blob.core.windows.net/circuits/circuits_cleansed"
df_silver.write.mode("overwrite").parquet(silver_path)
```

### 🥇 Gold Layer (Curated Zone)

**Purpose**: Business-ready, aggregated datasets optimized for analytics

**Characteristics**:
- Data format: Delta Lake (ACID compliant)
- Denormalized for performance
- Pre-calculated metrics
- Star/Snowflake schema
- Optimized for BI tools

**Business Logic Applied**:
1. **Aggregations**
   - Race statistics per season
   - Driver performance metrics
   - Constructor championship points
   - Circuit analysis

2. **Calculated Metrics**
   - Win rates
   - Podium percentages
   - Average finishing positions
   - Points per race
   - Fastest lap statistics

3. **Dimensional Modeling**
   - Fact tables (race_results, qualifying_results)
   - Dimension tables (drivers_dim, circuits_dim, seasons_dim)

**Directory Structure**:
```
gold/
├── fact_tables/
│   ├── race_results_fact/
│   ├── qualifying_results_fact/
│   └── championship_standings_fact/
├── dimension_tables/
│   ├── drivers_dim/
│   ├── constructors_dim/
│   ├── circuits_dim/
│   └── seasons_dim/
└── aggregated_metrics/
    ├── driver_performance_summary/
    ├── constructor_performance_summary/
    ├── circuit_statistics/
    └── season_analysis/
```

**Sample PySpark Code**:
```python
from pyspark.sql.functions import sum, avg, count, when, row_number
from pyspark.sql.window import Window

# Read from Silver
df_results = spark.read.parquet("wasbs://silver@{storage}.blob.core.windows.net/results/")
df_drivers = spark.read.parquet("wasbs://silver@{storage}.blob.core.windows.net/drivers/")

# Create driver performance summary
df_driver_performance = (df_results
    .join(df_drivers, "driver_id")
    .groupBy("driver_id", "driver_name", "season")
    .agg(
        count("*").alias("races_entered"),
        sum(when(col("position") == 1, 1).otherwise(0)).alias("wins"),
        sum(when(col("position") <= 3, 1).otherwise(0)).alias("podiums"),
        sum("points").alias("total_points"),
        avg("position").alias("avg_finish_position"),
        sum(when(col("fastest_lap_rank") == 1, 1).otherwise(0)).alias("fastest_laps")
    )
    .withColumn("win_rate", col("wins") / col("races_entered"))
    .withColumn("podium_rate", col("podiums") / col("races_entered"))
)

# Write to Gold (Delta Lake)
gold_path = "wasbs://gold@{storage}.blob.core.windows.net/driver_performance_summary"
df_driver_performance.write.format("delta").mode("overwrite").save(gold_path)
```

## 📂 Project Structure

```
F1-Data_Pipeline/
│
├── notebooks/
│   ├── 01_ingestion/
│   │   ├── ingest_circuits.py
│   │   ├── ingest_races.py
│   │   ├── ingest_drivers.py
│   │   ├── ingest_constructors.py
│   │   ├── ingest_results.py
│   │   ├── ingest_qualifying.py
│   │   ├── ingest_lap_times.py
│   │   └── ingest_pit_stops.py
│   │
│   ├── 02_transformation/
│   │   ├── transform_circuits.py
│   │   ├── transform_races.py
│   │   ├── transform_drivers.py
│   │   ├── transform_results.py
│   │   └── transform_qualifying.py
│   │
│   ├── 03_aggregation/
│   │   ├── create_driver_performance.py
│   │   ├── create_constructor_performance.py
│   │   ├── create_race_analysis.py
│   │   └── create_championship_standings.py
│   │
│   └── utils/
│       ├── common_functions.py
│       ├── config.py
│       └── schema_definitions.py
│
├── config/
│   ├── databricks_config.json
│   └── storage_config.json
│
├── tests/
│   ├── test_ingestion.py
│   ├── test_transformation.py
│   └── test_data_quality.py
│
├── docs/
│   ├── architecture.md
│   ├── data_dictionary.md
│   └── api_documentation.md
│
├── scripts/
│   ├── setup_environment.sh
│   └── deploy_pipeline.sh
│
├── .gitignore
├── requirements.txt
├── README.md
└── LICENSE
```

## 🚀 Setup Instructions

### Prerequisites

- Azure subscription with appropriate permissions
- Azure Databricks workspace
- Azure Blob Storage account
- Python 3.8 or higher
- Git

### Step 1: Clone the Repository

```bash
git clone https://github.com/vrukkodhara/F1-Data_Pipeline.git
cd F1-Data_Pipeline
```

### Step 2: Azure Resources Setup

#### 2.1 Create Azure Storage Account

```bash
# Using Azure CLI
az storage account create \
  --name <storage-account-name> \
  --resource-group <resource-group-name> \
  --location eastus \
  --sku Standard_LRS \
  --kind StorageV2 \
  --hierarchical-namespace true
```

#### 2.2 Create Containers

```bash
# Create containers for each layer
az storage container create --name bronze --account-name <storage-account-name>
az storage container create --name silver --account-name <storage-account-name>
az storage container create --name gold --account-name <storage-account-name>
```

#### 2.3 Get Storage Account Key

```bash
az storage account keys list \
  --resource-group <resource-group-name> \
  --account-name <storage-account-name>
```

### Step 3: Databricks Configuration

#### 3.1 Create Databricks Workspace

```bash
az databricks workspace create \
  --resource-group <resource-group-name> \
  --name <databricks-workspace-name> \
  --location eastus \
  --sku premium
```

#### 3.2 Mount Azure Blob Storage in Databricks

```python
# Run this in a Databricks notebook
storage_account_name = "<storage-account-name>"
storage_account_key = "<storage-account-key>"

# Mount Bronze layer
dbutils.fs.mount(
  source = f"wasbs://bronze@{storage_account_name}.blob.core.windows.net/",
  mount_point = "/mnt/f1dl/bronze",
  extra_configs = {f"fs.azure.account.key.{storage_account_name}.blob.core.windows.net": storage_account_key}
)

# Mount Silver layer
dbutils.fs.mount(
  source = f"wasbs://silver@{storage_account_name}.blob.core.windows.net/",
  mount_point = "/mnt/f1dl/silver",
  extra_configs = {f"fs.azure.account.key.{storage_account_name}.blob.core.windows.net": storage_account_key}
)

# Mount Gold layer
dbutils.fs.mount(
  source = f"wasbs://gold@{storage_account_name}.blob.core.windows.net/",
  mount_point = "/mnt/f1dl/gold",
  extra_configs = {f"fs.azure.account.key.{storage_account_name}.blob.core.windows.net": storage_account_key}
)
```

### Step 4: Install Dependencies

Create a Databricks cluster with the following configurations:

```
Databricks Runtime: 13.3 LTS (includes Apache Spark 3.4.1, Scala 2.12)
Worker Type: Standard_DS3_v2 (4 cores, 14 GB RAM)
Min Workers: 2
Max Workers: 8 (with autoscaling enabled)
```

Install required libraries on the cluster:
```
requests
pandas
delta-spark
```

### Step 5: Configure Environment Variables

Create a `config.py` file:

```python
# config.py
import os

# Azure Storage Configuration
STORAGE_ACCOUNT_NAME = "<your-storage-account>"
STORAGE_ACCOUNT_KEY = "<your-storage-key>"

# Mount Points
BRONZE_MOUNT_PATH = "/mnt/f1dl/bronze"
SILVER_MOUNT_PATH = "/mnt/f1dl/silver"
GOLD_MOUNT_PATH = "/mnt/f1dl/gold"

# API Configuration
ERGAST_API_BASE_URL = "http://ergast.com/api/f1"

# Processing Configuration
CURRENT_YEAR = 2024
START_YEAR = 1950
```

## ⚙️ Pipeline Execution

### Manual Execution

Execute notebooks in the following order:

#### Phase 1: Ingestion (Bronze Layer)
```bash
# In Databricks workspace
1. Run: notebooks/01_ingestion/ingest_circuits.py
2. Run: notebooks/01_ingestion/ingest_races.py
3. Run: notebooks/01_ingestion/ingest_drivers.py
4. Run: notebooks/01_ingestion/ingest_constructors.py
5. Run: notebooks/01_ingestion/ingest_results.py
6. Run: notebooks/01_ingestion/ingest_qualifying.py
```

#### Phase 2: Transformation (Silver Layer)
```bash
1. Run: notebooks/02_transformation/transform_circuits.py
2. Run: notebooks/02_transformation/transform_races.py
3. Run: notebooks/02_transformation/transform_drivers.py
4. Run: notebooks/02_transformation/transform_results.py
```

#### Phase 3: Aggregation (Gold Layer)
```bash
1. Run: notebooks/03_aggregation/create_driver_performance.py
2. Run: notebooks/03_aggregation/create_constructor_performance.py
3. Run: notebooks/03_aggregation/create_race_analysis.py
```

### Automated Execution

Using Databricks Jobs:

```python
# Create a job with dependent tasks
from databricks_cli.jobs.api import JobsApi
from databricks_cli.sdk import ApiClient

api_client = ApiClient(
  host="<databricks-host>",
  token="<databricks-token>"
)

jobs_api = JobsApi(api_client)

# Define job configuration
job_config = {
  "name": "F1-Data-Pipeline",
  "tasks": [
    {
      "task_key": "ingest_data",
      "notebook_task": {
        "notebook_path": "/notebooks/01_ingestion/master_ingestion",
        "base_parameters": {}
      },
      "new_cluster": {
        "spark_version": "13.3.x-scala2.12",
        "node_type_id": "Standard_DS3_v2",
        "num_workers": 2
      }
    },
    {
      "task_key": "transform_data",
      "depends_on": [{"task_key": "ingest_data"}],
      "notebook_task": {
        "notebook_path": "/notebooks/02_transformation/master_transformation",
        "base_parameters": {}
      }
    },
    {
      "task_key": "aggregate_data",
      "depends_on": [{"task_key": "transform_data"}],
      "notebook_task": {
        "notebook_path": "/notebooks/03_aggregation/master_aggregation",
        "base_parameters": {}
      }
    }
  ],
  "schedule": {
    "quartz_cron_expression": "0 0 2 * * ?",
    "timezone_id": "UTC"
  }
}

# Create the job
jobs_api.create_job(job_config)
```

## 📊 Data Schema

### Bronze Layer Schema Examples

**Circuits Raw**
```
root
 |-- circuitId: string
 |-- url: string
 |-- circuitName: string
 |-- Location: struct
 |    |-- lat: string
 |    |-- long: string
 |    |-- locality: string
 |    |-- country: string
 |-- ingestion_date: timestamp
```

**Results Raw**
```
root
 |-- resultId: string
 |-- raceId: string
 |-- driverId: string
 |-- constructorId: string
 |-- number: string
 |-- grid: string
 |-- position: string
 |-- points: string
 |-- laps: string
 |-- time: string
 |-- fastestLap: string
 |-- rank: string
 |-- fastestLapTime: string
 |-- fastestLapSpeed: string
 |-- statusId: string
 |-- ingestion_date: timestamp
```

### Silver Layer Schema Examples

**Circuits Cleansed**
```
root
 |-- circuit_id: string (not null)
 |-- circuit_name: string (not null)
 |-- location: string (not null)
 |-- country: string (not null)
 |-- latitude: double
 |-- longitude: double
 |-- altitude: integer
 |-- circuit_url: string
 |-- processing_date: timestamp
```

**Results Cleansed**
```
root
 |-- result_id: integer (not null)
 |-- race_id: integer (not null)
 |-- driver_id: string (not null)
 |-- constructor_id: string (not null)
 |-- grid_position: integer
 |-- final_position: integer
 |-- points_scored: float
 |-- laps_completed: integer
 |-- race_time_ms: long
 |-- fastest_lap_number: integer
 |-- fastest_lap_time_ms: long
 |-- fastest_lap_speed_kph: float
 |-- status: string
 |-- processing_date: timestamp
```

### Gold Layer Schema Examples

**Driver Performance Summary**
```
root
 |-- driver_id: string (not null)
 |-- driver_name: string (not null)
 |-- season: integer (not null)
 |-- races_entered: integer
 |-- wins: integer
 |-- podiums: integer
 |-- pole_positions: integer
 |-- fastest_laps: integer
 |-- total_points: float
 |-- championship_position: integer
 |-- avg_finish_position: double
 |-- avg_grid_position: double
 |-- win_rate: double
 |-- podium_rate: double
 |-- dnf_count: integer
 |-- dnf_rate: double
```

## ✨ Features

### Current Features

- ✅ **Automated Data Ingestion**: Scheduled extraction from Ergast API
- ✅ **Multi-Layer Architecture**: Bronze → Silver → Gold medallion architecture
- ✅ **Data Quality Checks**: Validation and cleansing at each layer
- ✅ **Scalable Processing**: Distributed processing using Apache Spark
- ✅ **ACID Compliance**: Delta Lake for reliable data operations
- ✅ **Historical Data**: Complete F1 history from 1950 to present
- ✅ **Incremental Loading**: Efficient updates for new data
- ✅ **Performance Optimization**: Partitioning and indexing strategies
- ✅ **Monitoring & Logging**: Comprehensive pipeline observability

### Data Quality Features

1. **Schema Validation**
   - Enforce expected data types
   - Check for required columns
   - Validate nested structures

2. **Data Completeness**
   - Identify missing values
   - Check for null percentages
   - Validate record counts

3. **Data Accuracy**
   - Range validation for numeric fields
   - Date logic checks
   - Cross-reference validation

4. **Duplicate Detection**
   - Identify exact duplicates
   - Check for logical duplicates
   - Deduplication strategies

## 🔮 Future Enhancements

- [ ] **Real-time Streaming**: Implement streaming ingestion during race weekends
- [ ] **Machine Learning**: Predictive models for race outcomes
- [ ] **Advanced Analytics**: Statistical analysis and visualizations
- [ ] **Data Catalog**: Implement Azure Purview for data governance
- [ ] **CI/CD Pipeline**: Automated testing and deployment
- [ ] **Cost Optimization**: Implement lifecycle policies and cold storage
- [ ] **API Development**: REST API for data consumption
- [ ] **Power BI Integration**: Pre-built dashboards and reports
- [ ] **Alerting System**: Automated alerts for pipeline failures
- [ ] **Data Versioning**: Enhanced time travel and rollback capabilities

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow PEP 8 style guide for Python code
- Use meaningful variable and function names
- Add docstrings to all functions
- Include unit tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Vrukkodhara**

- GitHub: [@vrukkodhara](https://github.com/vrukkodhara)

## 🙏 Acknowledgments

- **Ergast Developer API** - For providing comprehensive F1 data
- **Apache Spark Community** - For the powerful processing engine
- **Databricks** - For the excellent managed Spark platform
- **Microsoft Azure** - For reliable cloud infrastructure
- **F1 Community** - For the inspiration and passion

## 📞 Support

For questions or support:
- Open an issue in the GitHub repository
- Check existing documentation in the `/docs` folder
- Review Databricks and Azure documentation

---

**Made with ❤️ for Formula 1 enthusiasts and data engineers**

🏎️ *"Data is the new fuel in the race for insights"* 🏁
