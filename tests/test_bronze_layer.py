# Databricks notebook source
# MAGIC %md
# MAGIC # Test Bronze Layer
# MAGIC 
# MAGIC This notebook tests the bronze layer of the DAB ETL Framework.

# COMMAND ----------

# DBTITLE 1,Import required libraries
import unittest
from pyspark.sql import SparkSession
from pyspark.sql.types import StructType, StructField, StringType, IntegerType
import sys
import os

# Add the notebooks directory to the Python path
sys.path.append(os.path.abspath("../notebooks"))

# Mock the dlt module
class MockDLT:
    @staticmethod
    def table(*args, **kwargs):
        def decorator(func):
            return func
        return decorator
    
    @staticmethod
    def read(table_name):
        # Return a mock dataframe
        return spark.createDataFrame([], StructType([]))

# Mock the dlt module
sys.modules["dlt"] = MockDLT()

# Import the bronze layer module
import bronze_layer

# COMMAND ----------

# DBTITLE 1,Define test data
# Create a test schema
test_schema = StructType([
    StructField("id", StringType(), True),
    StructField("name", StringType(), True),
    StructField("email", StringType(), True),
    StructField("age", IntegerType(), True),
    StructField("city", StringType(), True),
    StructField("registration_date", StringType(), True),
    StructField("status", StringType(), True)
])

# Create test data
test_data = [
    ("1", "John Doe", "john.doe@example.com", 32, "New York", "2023-01-15", "active"),
    ("2", "Jane Smith", "jane.smith@example.com", 28, "Los Angeles", "2023-02-20", "active"),
    ("3", "Bob Johnson", "bob.johnson@example.com", 45, "Chicago", "2023-01-10", "inactive")
]

# Create a test dataframe
test_df = spark.createDataFrame(test_data, test_schema)

# COMMAND ----------

# DBTITLE 1,Define test class
class TestBronzeLayer(unittest.TestCase):
    def test_bronze_users(self):
        """Test the bronze_users function."""
        # Mock the spark.read.format().option().option().load() chain
        bronze_layer.spark.read = lambda: self
        self.format = lambda _: self
        self.option = lambda *args, **kwargs: self
        self.load = lambda _: test_df
        
        # Call the bronze_users function
        result_df = bronze_layer.bronze_users()
        
        # Check that the result has the expected number of rows
        self.assertEqual(result_df.count(), 3)
        
        # Check that the result has the expected columns
        expected_columns = ["id", "name", "email", "age", "city", "registration_date", "status", "_ingest_timestamp", "_source"]
        self.assertEqual(set(result_df.columns), set(expected_columns))
        
        # Check that the _source column has the expected value
        self.assertEqual(result_df.select("_source").first()[0], "sample_data.csv")

# COMMAND ----------

# DBTITLE 1,Run the tests
# Create a test suite
suite = unittest.TestSuite()
suite.addTest(TestBronzeLayer("test_bronze_users"))

# Run the tests
runner = unittest.TextTestRunner()
result = runner.run(suite)

# Print the result
print(f"Tests run: {result.testsRun}")
print(f"Errors: {len(result.errors)}")
print(f"Failures: {len(result.failures)}")
