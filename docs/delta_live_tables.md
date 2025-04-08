# Delta Live Tables (DLT)

Delta Live Tables (DLT) is a declarative framework for building reliable, maintainable, and testable data pipelines on Databricks. This document explains Delta Live Tables as implemented in the DAB ETL Framework.

## Overview

Delta Live Tables simplifies ETL development by allowing you to define data transformations using SQL or Python, with built-in support for data quality, error handling, and pipeline orchestration.

Key features of Delta Live Tables include:

- Declarative data transformations
- Automatic dependency management
- Data quality enforcement
- Incremental processing
- Error handling and recovery
- Monitoring and observability

## Key Concepts

### Tables and Views

In DLT, you can define two types of data objects:

- **Live Tables**: Materialized Delta tables that store data
- **Live Views**: Non-materialized views that are computed on-demand

### Transformations

Transformations in DLT are defined using the `@dlt.table` decorator in Python or the `CREATE LIVE TABLE` statement in SQL. These transformations define how data flows from one table to another.

### Expectations

Expectations are data quality rules that can be applied to tables. They allow you to define constraints that data must satisfy, and specify how to handle violations.

### Pipeline

A pipeline is a collection of tables, views, and their dependencies. DLT automatically determines the execution order based on the dependencies between tables.

## Implementation in DAB ETL Framework

In the DAB ETL Framework, Delta Live Tables are used to implement the medallion architecture:

### Bronze Layer

The bronze layer is implemented in `notebooks/bronze_layer.py`:

```python
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
    """
    return (
        spark.read.format("csv")
            .option("header", "true")
            .option("inferSchema", "true")
            .load(source_data_path)
            .withColumn("_ingest_timestamp", current_timestamp())
            .withColumn("_source", lit("sample_data.csv"))
    )
```

### Silver Layer

The silver layer is implemented in `notebooks/silver_layer.py`:

```python
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
    """
    return (
        dlt.read(bronze_table_name)
            # Transformations
            ...
    )
```

### Gold Layer

The gold layer is implemented in `notebooks/gold_layer.py`:

```python
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
    """
    return (
        dlt.read(silver_table_name)
            # Transformations
            ...
    )
```

### Pipeline Configuration

The DLT pipeline is configured in `jobs/dlt_pipeline.yml`:

```yaml
resources:
  pipelines:
    bronze_silver_gold_pipeline:
      name: "bronze-silver-gold-pipeline"
      target: "${target}"
      libraries:
        - notebook:
            path: "${var.root_path}/notebooks/bronze_layer"
        - notebook:
            path: "${var.root_path}/notebooks/silver_layer"
        - notebook:
            path: "${var.root_path}/notebooks/gold_layer"
      configuration:
        # Pipeline configuration
        ...
```

## Benefits of Delta Live Tables

Delta Live Tables provide several benefits:

- **Simplicity**: Declarative syntax simplifies ETL development
- **Reliability**: Built-in error handling and recovery
- **Data Quality**: Expectations enforce data quality rules
- **Maintainability**: Clear dependencies and documentation
- **Testability**: Modular design enables unit testing
- **Observability**: Built-in monitoring and logging
- **Performance**: Optimized execution and incremental processing

## Workflow

The typical workflow for working with Delta Live Tables is:

1. **Define**: Define tables and transformations in notebooks
2. **Configure**: Configure the pipeline in YAML
3. **Deploy**: Deploy the pipeline using Databricks Asset Bundles
4. **Monitor**: Monitor the pipeline execution
5. **Update**: Update the pipeline as needed and redeploy

## Conclusion

Delta Live Tables provide a powerful framework for building reliable, maintainable, and testable data pipelines. By using DLT, the DAB ETL Framework simplifies ETL development and ensures data quality at each stage of the medallion architecture.

This approach follows software engineering best practices and makes the ETL pipeline more robust and scalable.
