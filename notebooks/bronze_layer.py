# Databricks notebook source
# MAGIC %md
# MAGIC # Bronze Layer - Data Ingestion
# MAGIC 
# MAGIC This notebook is part of the DAB ETL Framework and is responsible for ingesting raw data into the bronze layer.
# MAGIC 
# MAGIC ## Overview
# MAGIC 
# MAGIC The bronze layer represents the raw data ingested from various sources with minimal transformations.
# MAGIC 
# MAGIC In this example, we're ingesting data from a CSV file, but in a real-world scenario, this could be data from:
# MAGIC - Cloud storage (S3, ADLS, etc.)
# MAGIC - Streaming sources (Kafka, Event Hubs, etc.)
# MAGIC - JDBC sources
# MAGIC - And more

# COMMAND ----------

# DBTITLE 1,Import required libraries
import dlt
from pyspark.sql.functions import current_timestamp, lit, col

# COMMAND ----------

# DBTITLE 1,Define configuration parameters
# These parameters can be overridden when the pipeline is created
source_data_path = spark.conf.get("source_data_path", "/Workspace/Repos/dab-etl-framework/data/sample_data.csv")
bronze_table_name = spark.conf.get("bronze_table_name", "bronze_users")

# COMMAND ----------

# DBTITLE 1,Define the bronze table
@dlt.table(
    name=bronze_table_name,
    comment="Raw user data ingested from CSV",
    table_properties={
        "quality": "bronze",
        "pipelines.autoOptimize.managed": "true"
    }
)
def bronze_users():
    """
    Ingest raw user data from CSV file into the bronze layer.
    
    This function reads data from a CSV file and adds metadata columns:
    - _ingest_timestamp: The timestamp when the data was ingested
    - _source: The source of the data
    """
    return (
        spark.read.format("csv")
            .option("header", "true")
            .option("inferSchema", "true")
            .load(source_data_path)
            .withColumn("_ingest_timestamp", current_timestamp())
            .withColumn("_source", lit("sample_data.csv"))
    )
