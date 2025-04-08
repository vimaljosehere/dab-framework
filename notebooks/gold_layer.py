# Databricks notebook source
# MAGIC %md
# MAGIC # Gold Layer - Business Aggregations
# MAGIC 
# MAGIC This notebook is part of the DAB ETL Framework and is responsible for creating business-ready views of the data from the silver layer.
# MAGIC 
# MAGIC ## Overview
# MAGIC 
# MAGIC The gold layer represents business-level aggregations and views that are ready for consumption by end users, dashboards, and applications.
# MAGIC 
# MAGIC In this example, we're creating:
# MAGIC - A user dimension table
# MAGIC - A user status summary table
# MAGIC - A city-based user distribution table

# COMMAND ----------

# DBTITLE 1,Import required libraries
import dlt
from pyspark.sql.functions import col, count, avg, min, max, current_timestamp, lit, month, year, dayofmonth

# COMMAND ----------

# DBTITLE 1,Define configuration parameters
# These parameters can be overridden when the pipeline is created
silver_table_name = spark.conf.get("silver_table_name", "silver_users")
gold_user_dim_table_name = spark.conf.get("gold_user_dim_table_name", "gold_user_dimension")
gold_status_summary_table_name = spark.conf.get("gold_status_summary_table_name", "gold_status_summary")
gold_city_distribution_table_name = spark.conf.get("gold_city_distribution_table_name", "gold_city_distribution")

# COMMAND ----------

# DBTITLE 1,Create user dimension table
@dlt.table(
    name=gold_user_dim_table_name,
    comment="User dimension table with enriched information",
    table_properties={
        "quality": "gold",
        "pipelines.autoOptimize.managed": "true"
    }
)
def gold_user_dimension():
    """
    Create a user dimension table from the silver layer.
    
    This function:
    - Selects relevant user attributes
    - Adds derived columns (registration month, year, etc.)
    - Adds metadata columns
    """
    return (
        dlt.read(silver_table_name)
            .select(
                col("id"),
                col("name"),
                col("email"),
                col("age"),
                col("city"),
                col("registration_date"),
                col("status"),
                # Add derived columns
                year(col("registration_date")).alias("registration_year"),
                month(col("registration_date")).alias("registration_month"),
                dayofmonth(col("registration_date")).alias("registration_day")
            )
            # Add gold layer metadata
            .withColumn("_gold_timestamp", current_timestamp())
            .withColumn("_gold_process", lit("dimension_creation"))
    )

# COMMAND ----------

# DBTITLE 1,Create status summary table
@dlt.table(
    name=gold_status_summary_table_name,
    comment="Summary of users by status",
    table_properties={
        "quality": "gold",
        "pipelines.autoOptimize.managed": "true"
    }
)
def gold_status_summary():
    """
    Create a summary table of users by status.
    
    This function:
    - Groups users by status
    - Calculates count, average age, min/max age for each status
    - Adds metadata columns
    """
    return (
        dlt.read(silver_table_name)
            .groupBy("status")
            .agg(
                count("id").alias("user_count"),
                avg("age").alias("average_age"),
                min("age").alias("min_age"),
                max("age").alias("max_age")
            )
            # Add gold layer metadata
            .withColumn("_gold_timestamp", current_timestamp())
            .withColumn("_gold_process", lit("status_aggregation"))
    )

# COMMAND ----------

# DBTITLE 1,Create city distribution table
@dlt.table(
    name=gold_city_distribution_table_name,
    comment="Distribution of users by city",
    table_properties={
        "quality": "gold",
        "pipelines.autoOptimize.managed": "true"
    }
)
def gold_city_distribution():
    """
    Create a distribution table of users by city.
    
    This function:
    - Groups users by city
    - Calculates count, average age, min/max age for each city
    - Adds metadata columns
    """
    return (
        dlt.read(silver_table_name)
            .groupBy("city")
            .agg(
                count("id").alias("user_count"),
                avg("age").alias("average_age"),
                min("age").alias("min_age"),
                max("age").alias("max_age")
            )
            # Add gold layer metadata
            .withColumn("_gold_timestamp", current_timestamp())
            .withColumn("_gold_process", lit("city_aggregation"))
    )
