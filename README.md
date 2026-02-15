# 🏎️ Formula 1 Data Pipeline

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoft-azure&logoColor=white)
![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![PySpark](https://img.shields.io/badge/Apache_Spark-E25A1C?style=for-the-badge&logo=apache-spark&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Delta Lake](https://img.shields.io/badge/Delta_Lake-00ADD8?style=for-the-badge&logo=delta&logoColor=white)

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)  
- [Data Source](#data-source)
- [Data Pipeline Layers](#data-pipeline-layers)
- [Tech Stack](#tech-stack)
- [Setup Instructions](#setup-instructions)
- [Features](#features)

## 🎯 Overview

This project implements an end-to-end **ETL data pipeline** for Formula 1 racing data using cloud-native technologies. The pipeline extracts historical F1 data from **multiple file sources** via the Ergast Developer API, processes it using **Apache Spark on Databricks**, and stores it in a **four-layered data lake architecture** on Azure Blob Storage.

### Key Highlights
✅ **Multi-Source Data Ingestion** from multiple file sources  
✅ **Schema-on-Read** with External Tables in Raw zone  
✅ **ACID-Compliant Ingestion** using Delta Lake in Bronze layer  
✅ **Data Quality & Validation** in Silver layer  
✅ **Analytics-Ready Datasets** in Gold layer  
✅ **4-Layer Medallion Architecture**: Raw → Bronze → Silver → Gold

## 🏗️ Architecture

### High-Level Data Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    F1 DATA PIPELINE                           │
└──────────────────────────────────────────────────────────────┘

   📥 Data Source                
   Ergast F1 API                 
   Multiple Files                
         │                       
         │ Extract & Land        
         ▼                       
┌──────────────────────────────────────────────────────────────┐
│  🗂️ RAW ZONE - Landing Area                                  │
│  • Multiple Files (JSON/CSV)                                 │
│  • External Hive Tables                                      │
│  • Schema-on-Read                                            │
│  • Immediate Analysis                                        │
└──────────────────────────────────────────────────────────────┘
         │                       
         │ Read via External Tables
         ▼                       
┌──────────────────────────────────────────────────────────────┐
│  ⚙️ AZURE DATABRICKS                                          │
│  PySpark Notebooks for Processing                            │
│  • Ingestion → Transformation → Aggregation                 │
└──────────────────────────────────────────────────────────────┘
         │                       
         ├──────┬──────────┬────────────┐
         ▼      ▼          ▼            ▼
┌──────────────────────────────────────────────────────────────┐
│  💾 AZURE BLOB STORAGE (Data Lake)                            │
│                                                               │
│  🥉 BRONZE     →  🥈 SILVER    →   🥇 GOLD                     │
│  Ingestion        Processed        Presentation              │
│  Delta Tables     Delta Tables     Delta Tables              │
│  ACID Compliant   Cleansed Data    Business Metrics          │
└──────────────────────────────────────────────────────────────┘
         │                       
         ▼                       
   📊 Analytics & BI             
   Power BI | Tableau            
```

### 4-Layer Medallion Architecture

```
┌───────────────────────────────────────────────────────────┐
│         RAW → BRONZE → SILVER → GOLD                      │
└───────────────────────────────────────────────────────────┘

🗂️  LAYER 1: RAW ZONE
    Purpose: Landing zone for multiple file sources
    Format: JSON/CSV files
    Tables: External Hive tables (schema-on-read)
    Benefits: 
    ✓ Immediate data availability
    ✓ Zero duplication  
    ✓ Fast exploration
    ✓ Ad-hoc SQL queries
              ↓
              
🥉 LAYER 2: BRONZE (Ingestion)
    Purpose: ACID-compliant ingestion
    Format: Delta Lake
    Features:
    ✓ ACID transactions
    ✓ Time travel
    ✓ MERGE operations
    ✓ Partitioned data
    ✓ Audit columns
              ↓
              
🥈 LAYER 3: SILVER (Processed)
    Purpose: Cleansed & validated data
    Format: Delta Lake  
    Transformations:
    ✓ Data quality checks
    ✓ Deduplication
    ✓ Standardization
    ✓ Type casting
    ✓ Business rules
              ↓
              
🥇 LAYER 4: GOLD (Presentation)
    Purpose: Analytics-ready datasets
    Format: Delta Lake
    Content:
    ✓ Fact tables
    ✓ Dimension tables
    ✓ Pre-aggregated metrics
    ✓ Star schema
    ✓ Business KPIs
```

## 📊 Data Source

### Ergast Developer API

**Comprehensive F1 data from 1950 to present**

- 🌐 **API**: [http://ergast.com/mrd/](http://ergast.com/mrd/)
- 📦 **Dataset**: [http://ergast.com/mrd/db/](http://ergast.com/mrd/db/)
- 📅 **Coverage**: 1950 - Present (70+ years)
- 📝 **Format**: JSON/XML/CSV

**Available Endpoints:**
- Circuits, Races, Drivers, Constructors
- Results, Qualifying, Lap Times, Pit Stops
- Driver Standings, Constructor Standings
- Sprint Results

## 📁 Data Pipeline Layers

### 🗂️ LAYER 1: Raw Zone

**Purpose**: Landing area for multiple file sources

**Key Features:**
- Multiple files from Ergast API (JSON/CSV)
- External Hive tables for schema-on-read
- No data movement or duplication
- Immediate SQL query capability
- Zero processing - data as-is

**Example: Creating External Table**
```python
spark.sql("""
CREATE EXTERNAL TABLE f1_raw.circuits (
    circuitId STRING,
    circuitName STRING,
    location STRUCT<lat:STRING, long:STRING, 
                    locality:STRING, country:STRING>,
    url STRING
) USING JSON
LOCATION 'abfss://raw@storage.dfs.core.windows.net/circuits/'
""")

# Query immediately without data movement
spark.sql("SELECT * FROM f1_raw.circuits").show()
```

---

### 🥉 LAYER 2: Bronze (Ingestion)

**Purpose**: ACID-compliant ingestion with Delta Lake

**Key Features:**
- Delta Lake format with ACID properties
- Data read from Raw zone external tables
- MERGE operations for idempotency
- Partitioned by year/race
- Time travel enabled
- Audit columns (ingestion_date, source_file)

**Example: Bronze Ingestion**
```python
from delta.tables import DeltaTable
from pyspark.sql.functions import current_timestamp, lit

# Read from Raw external table
df_raw = spark.sql("SELECT * FROM f1_raw.circuits")

# Add audit columns
df_bronze = df_raw \
    .withColumn("ingestion_date", current_timestamp()) \
    .withColumn("source", lit("ergast_api"))

# Write as Delta with MERGE
bronze_path = "abfss://bronze@storage.dfs.core.windows.net/circuits_bronze"

if DeltaTable.isDeltaTable(spark, bronze_path):
    deltaTable = DeltaTable.forPath(spark, bronze_path)
    deltaTable.alias("target").merge(
        df_bronze.alias("source"),
        "target.circuitId = source.circuitId"
    ).whenMatchedUpdateAll() \
     .whenNotMatchedInsertAll() \
     .execute()
else:
    df_bronze.write.format("delta").save(bronze_path)

# Optimize for performance
spark.sql(f"OPTIMIZE delta.`{bronze_path}`")
```

---

### 🥈 LAYER 3: Silver (Processed)

**Purpose**: Cleansed, validated, standardized data

**Key Features:**
- Delta Lake format
- Data quality checks applied
- Deduplication
- NULL handling
- Type casting
- Standardized column names (snake_case)
- Business rule validation

**Example: Silver Transformation**
```python
from pyspark.sql.functions import col, trim, upper, coalesce

# Read from Bronze
df_bronze = spark.read.format("delta").load(bronze_path)

# Apply transformations
df_silver = (df_bronze
    .dropDuplicates(["circuitId"])
    .withColumnRenamed("circuitId", "circuit_id")
    .withColumnRenamed("circuitName", "circuit_name")
    .withColumn("circuit_name", trim(col("circuit_name")))
    .withColumn("country", upper(col("location.country")))
    .withColumn("latitude", col("location.lat").cast("double"))
    .withColumn("longitude", col("location.long").cast("double"))
    .withColumn("locality", coalesce(col("location.locality"), 
                                     lit("Unknown")))
    .filter(col("circuit_id").isNotNull())
    .drop("location", "source")
)

# Write to Silver
silver_path = "abfss://silver@storage.dfs.core.windows.net/circuits_processed"
df_silver.write.format("delta").mode("overwrite").save(silver_path)
```

---

### 🥇 LAYER 4: Gold (Presentation)

**Purpose**: Analytics-ready business datasets

**Key Features:**
- Delta Lake format
- Star/Snowflake schema
- Fact & dimension tables
- Pre-calculated metrics
- Denormalized for performance
- Optimized for BI tools

**Example: Gold Aggregation**
```python
from pyspark.sql.functions import sum, avg, count, when, dense_rank
from pyspark.sql.window import Window

# Read from Silver
df_results = spark.read.format("delta").load(results_silver_path)
df_drivers = spark.read.format("delta").load(drivers_silver_path)

# Create driver performance summary
df_gold = (df_results.join(df_drivers, "driver_id")
    .groupBy("driver_id", "driver_name", "season")
    .agg(
        count("*").alias("races_entered"),
        sum(when(col("final_position") == 1, 1).otherwise(0)).alias("wins"),
        sum(when(col("final_position") <= 3, 1).otherwise(0)).alias("podiums"),
        sum("points_scored").alias("total_points"),
        avg("final_position").alias("avg_finish_position")
    )
    .withColumn("win_rate", col("wins") / col("races_entered") * 100)
    .withColumn("podium_rate", col("podiums") / col("races_entered") * 100)
)

# Add championship ranking
window_spec = Window.partitionBy("season").orderBy(col("total_points").desc())
df_gold = df_gold.withColumn("championship_position", dense_rank().over(window_spec))

# Write to Gold
gold_path = "abfss://gold@storage.dfs.core.windows.net/driver_performance"
df_gold.write.format("delta").partitionBy("season").save(gold_path)
```

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| **Cloud** | Microsoft Azure |
| **Storage** | Azure Blob Storage (ADLS Gen2) |
| **Processing** | Apache Spark (PySpark) |
| **Compute** | Azure Databricks |
| **Format** | Delta Lake |
| **External Tables** | Hive Metastore |
| **Language** | Python 3.8+ |

**Why Delta Lake?**
- ✅ ACID transactions
- ✅ Time travel (versioning)
- ✅ Schema enforcement & evolution
- ✅ MERGE/UPDATE/DELETE operations
- ✅ Performance optimization (OPTIMIZE, Z-ORDER)

## 🚀 Setup Instructions

### Prerequisites
- Azure subscription
- Azure Databricks workspace
- Azure Storage Account (ADLS Gen2)

### Quick Setup

```bash
# 1. Create Storage Account
az storage account create \
  --name f1datalake001 \
  --resource-group f1-rg \
  --location eastus \
  --sku Standard_LRS \
  --hierarchical-namespace true

# 2. Create containers
az storage container create --name raw --account-name f1datalake001
az storage container create --name bronze --account-name f1datalake001  
az storage container create --name silver --account-name f1datalake001
az storage container create --name gold --account-name f1datalake001

# 3. Create Databricks workspace
az databricks workspace create \
  --resource-group f1-rg \
  --name f1-databricks \
  --location eastus \
  --sku premium
```

### Mount Storage in Databricks

```python
# Mount all layers
storage_account = "f1datalake001"
key = "<storage-key>"

configs = {f"fs.azure.account.key.{storage_account}.dfs.core.windows.net": key}

for layer in ["raw", "bronze", "silver", "gold"]:
    dbutils.fs.mount(
        source=f"abfss://{layer}@{storage_account}.dfs.core.windows.net/",
        mount_point=f"/mnt/f1dl/{layer}",
        extra_configs=configs
    )
```

## ✨ Features

### Implemented
✅ 4-Layer Medallion Architecture  
✅ External Tables in Raw Zone  
✅ Delta Lake Across All Layers  
✅ ACID Transactions  
✅ Time Travel Capability  
✅ Data Quality Framework  
✅ Incremental Loading (MERGE)  
✅ Partitioning Strategy  
✅ Performance Optimization  
✅ 70+ Years of F1 Data  

### Future Enhancements
🔮 Real-time Streaming  
🔮 Machine Learning Models  
🔮 Power BI Dashboards  
🔮 CI/CD Pipeline  
🔮 Advanced Analytics  
🔮 Data Catalog (Unity Catalog)  

## 👤 Author

**Vrukkodhara**
- GitHub: [@vrukkodhara](https://github.com/vrukkodhara)

## 📄 License

MIT License

---

**Made with ❤️ for F1 enthusiasts and data engineers**

🏎️ *"Every lap counts, every layer matters"* 🏁
