# Databricks Asset Bundle (DAB) ETL Framework

A parameterized framework for managing ETL pipelines from bronze to silver to gold using Delta Live Tables (DLT) in Databricks.

## Overview

This framework provides a structured approach to building and deploying ETL pipelines using Databricks Asset Bundles (DAB) and Delta Live Tables (DLT). It follows the medallion architecture pattern with bronze, silver, and gold layers.

- **Bronze Layer**: Raw data ingestion with minimal transformations
- **Silver Layer**: Cleaned, validated, and transformed data
- **Gold Layer**: Business-ready aggregations and views

The framework is designed to be:

- **Parameterized**: Easily configurable for different environments and use cases
- **Modular**: Clear separation of concerns between layers
- **Scalable**: Works for small and large datasets
- **Maintainable**: Well-documented and follows best practices
- **CI/CD Ready**: Integrated with GitHub Actions for automated deployment

## Project Structure

```
dab-framework/
├── .github/
│   └── workflows/
│       └── dab-cicd.yml         # GitHub Actions workflow for CI/CD
├── data/
│   └── sample_data.csv          # Sample data for testing
├── docs/
│   └── ...                      # Additional documentation
├── jobs/
│   └── dlt_pipeline.yml         # DLT pipeline configuration
├── notebooks/
│   ├── bronze_layer.py          # Bronze layer DLT notebook
│   ├── silver_layer.py          # Silver layer DLT notebook
│   └── gold_layer.py            # Gold layer DLT notebook
├── resources/
│   └── catalog.yml              # Catalog and schema configuration
├── scripts/
│   └── ...                      # Utility scripts
├── tests/
│   └── ...                      # Unit and integration tests
├── config/
│   └── ...                      # Additional configuration files
├── databricks.yml               # Main DAB configuration file
└── README.md                    # This file
```

## Getting Started

### Prerequisites

- Databricks workspace
- Databricks CLI installed and configured
- GitHub account (for CI/CD)

### Setup

1. Clone this repository:

```bash
git clone https://github.com/yourusername/dab-etl-framework.git
cd dab-etl-framework
```

2. Configure your Databricks workspaces in `databricks.yml`:

```yaml
targets:
  development:
    workspace:
      host: "https://your-dev-workspace.cloud.databricks.com"
  test:
    workspace:
      host: "https://your-test-workspace.cloud.databricks.com"
  production:
    workspace:
      host: "https://your-prod-workspace.cloud.databricks.com"
```

3. Set up GitHub secrets for CI/CD:

- `DATABRICKS_HOST_DEV`: URL of your development workspace
- `DATABRICKS_TOKEN_DEV`: Access token for your development workspace
- `DATABRICKS_HOST_TEST`: URL of your test workspace
- `DATABRICKS_TOKEN_TEST`: Access token for your test workspace
- `DATABRICKS_HOST_PROD`: URL of your production workspace
- `DATABRICKS_TOKEN_PROD`: Access token for your production workspace

### Local Development

1. Validate the bundle:

```bash
databricks bundle validate
```

2. Deploy to your development workspace:

```bash
databricks bundle deploy --target development
```

## Medallion Architecture

This framework implements the medallion architecture, which organizes data into three layers:

### Bronze Layer

- Raw data ingestion
- Minimal transformations
- Metadata enrichment
- Schema inference

### Silver Layer

- Data cleaning and standardization
- Data validation and quality checks
- Type conversions
- Business rule application

### Gold Layer

- Aggregations and summaries
- Business-specific views
- Denormalized tables for analytics
- Ready for consumption by end users

## Delta Live Tables

The framework uses Delta Live Tables (DLT) to implement the ETL pipeline. DLT provides:

- Declarative data transformations
- Automatic dependency management
- Data quality enforcement
- Incremental processing
- Error handling and recovery

## Parameterization

The framework is highly parameterized, allowing for easy configuration:

- Environment-specific settings (dev, test, prod)
- Table names and paths
- Cluster configurations
- Data sources
- Schema definitions

## CI/CD with GitHub Actions

The included GitHub Actions workflow automates the deployment process:

1. **Validate**: Checks the bundle for errors
2. **Deploy to Development**: Automatically deploys to the development environment on push to main
3. **Deploy to Test**: Deploys to the test environment after successful deployment to development
4. **Deploy to Production**: Manual trigger required for production deployment

## Customization

To adapt this framework for your specific use case:

1. Modify the sample data or connect to your own data sources
2. Update the transformation logic in the bronze, silver, and gold layer notebooks
3. Adjust the table schemas and business rules
4. Configure the pipeline parameters in `databricks.yml`

## Best Practices

This framework follows these best practices:

- **Separation of Concerns**: Each layer has a specific purpose
- **Parameterization**: Environment-specific configurations
- **Metadata Tracking**: Each record includes processing metadata
- **Data Quality**: Expectations and constraints at each layer
- **Documentation**: Comprehensive inline and external documentation
- **Testing**: Unit and integration tests
- **CI/CD**: Automated deployment pipeline
- **Version Control**: All code and configuration in Git

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
