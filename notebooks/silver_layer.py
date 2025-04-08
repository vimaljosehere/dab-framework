# Databricks notebook source
# MAGIC %md
# MAGIC # Silver Layer - Data Transformation
# MAGIC 
# MAGIC This notebook is part of the DAB ETL Framework and is responsible for transforming data from the bronze layer to the silver layer.
# MAGIC 
# MAGIC ## Overview
# MAGIC 
# MAGIC The silver layer represents cleaned, validated, and transformed data from the bronze layer.
# MAGIC 
# MAGIC In this example, we're:
# MAGIC - Validating data types
# MAGIC - Cleaning and standardizing data
# MAGIC - Applying business rules
# MAGIC - Adding data quality expectations

# COMMAND ----------

# DBTITLE 1,Import required libraries
import dlt
from pyspark.sql.functions import col, upper, to_date, when, current_timestamp, lit

# COMMAND ----------

# DBTITLE 1,Define configuration parameters
# These parameters can be overridden when the pipeline is created
bronze_table_name = spark.conf.get("bronze_table_name", "bronze_users")
silver_table_name = spark.conf.get("silver_table_name", "silver_users")

# COMMAND ----------

# DBTITLE 1,Define data quality expectations
@dlt.expect_all({
    "valid_id": "id IS NOT NULL",
    "valid_email": "email IS NOT NULL AND email LIKE '%@%.%'",
    "valid_age": "age IS NOT NULL AND age > 0 AND age < 120",
    "valid_status": "status IN ('active', 'inactive', 'pending')"
})
@dlt.expect_or_drop("valid_registration_date", "registration_date IS NOT NULL")
@dlt.table(
    name=silver_table_name,
    comment="Cleaned and validated user data",
    table_properties={
        "quality": "silver",
        "pipelines.autoOptimize.managed": "true"
    }
)
def silver_users():
    """
    Transform and clean user data from the bronze layer.
    
    This function:
    - Standardizes column names
    - Converts data types
    - Standardizes values (e.g., city names to uppercase)
    - Adds metadata columns
    """
    return (
        dlt.read(bronze_table_name)
            # Standardize column names and data types
            .select(
                col("id").cast("integer"),
                col("name"),
                col("email"),
                col("age").cast("integer"),
                upper(col("city")).alias("city"),
                to_date(col("registration_date"), "yyyy-MM-dd").alias("registration_date"),
                col("status"),
                # Carry over metadata columns
                col("_ingest_timestamp"),
                col("_source")
            )
            # Add silver layer metadata
            .withColumn("_silver_timestamp", current_timestamp())
            .withColumn("_silver_process", lit("data_cleaning"))
    )
