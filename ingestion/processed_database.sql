-- Databricks notebook source
CREATE EXTERNAL LOCATION f1_ext_processed
URL 'abfss://processed@f1dlnagsa.dfs.core.windows.net/'
WITH (CREDENTIAL adls_credential);

-- COMMAND ----------

CREATE DATABASE IF NOT EXISTS f1_processed
MANAGED LOCATION  "abfss://processed@f1dlnagsa.dfs.core.windows.net/"

-- COMMAND ----------

DESC DATABASE f1_processed;

-- COMMAND ----------

SHOW DATABASES;


-- COMMAND ----------

-- SHOW TABLES IN f1_processed

-- COMMAND ----------

-- Drop all tables in the database
-- USE f1_processed;
-- DROP TABLE IF EXISTS circuits;
-- DROP TABLE IF EXISTS constructors;
-- DROP TABLE IF EXISTS drivers;
-- DROP TABLE IF EXISTS lap_times;
-- DROP TABLE IF EXISTS pit_stops;
-- DROP TABLE IF EXISTS qualifying;
-- DROP TABLE IF EXISTS races;
-- DROP TABLE IF EXISTS results;

-- -- Drop the database
-- DROP DATABASE IF EXISTS f1_processed;
