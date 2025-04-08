# Databricks Asset Bundles (DAB)

Databricks Asset Bundles (DAB) is an infrastructure-as-code (IaC) approach to managing Databricks resources. This document explains Databricks Asset Bundles as implemented in the DAB ETL Framework.

## Overview

Databricks Asset Bundles allow you to define, deploy, and manage Databricks resources using code. This enables version control, CI/CD integration, and consistent deployment across environments.

A bundle is a collection of resources defined in YAML files, along with associated code (notebooks, libraries, etc.). These resources can include:

- Jobs
- Pipelines (Delta Live Tables)
- Workflows
- Clusters
- Notebooks
- SQL objects (dashboards, queries, etc.)
- MLflow models
- And more

## Key Concepts

### Bundle Configuration

The main configuration file for a bundle is `databricks.yml`, which defines:

- Bundle name
- Targets (environments)
- Variables
- Resource references

### Targets

Targets represent different environments (e.g., development, test, production) where the bundle can be deployed. Each target can have different configurations, allowing for environment-specific settings.

### Variables

Variables allow for parameterization of the bundle, making it flexible and reusable. Variables can be defined with default values and overridden at deployment time.

### Resources

Resources are the Databricks assets that are managed by the bundle. These can include jobs, pipelines, workflows, and more.

## Implementation in DAB ETL Framework

In the DAB ETL Framework, Databricks Asset Bundles are used to manage:

### Bundle Configuration

The main configuration file is `databricks.yml`, which defines:

```yaml
bundle:
  name: dab-etl-framework

targets:
  development:
    workspace:
      host: ${var.dev_workspace_url}
  
  test:
    workspace:
      host: ${var.test_workspace_url}
  
  production:
    workspace:
      host: ${var.prod_workspace_url}

variables:
  # Workspace URLs, catalogs, schemas, paths, etc.
  ...
```

### Delta Live Tables Pipeline

The DLT pipeline is defined in `jobs/dlt_pipeline.yml`:

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

### Catalog and Schema

The catalog and schema are defined in `resources/catalog.yml`:

```yaml
catalogs:
  dev_catalog:
    name: ${var.dev_catalog}
    comment: "Development catalog for the DAB ETL framework"
    properties:
      purpose: "development"
  
  # Test and production catalogs
  ...

schemas:
  dev_schema:
    catalog_name: ${var.dev_catalog}
    name: ${var.dev_schema}
    comment: "Development schema for the DAB ETL framework"
  
  # Test and production schemas
  ...
```

## Benefits of Databricks Asset Bundles

Databricks Asset Bundles provide several benefits:

- **Version Control**: All resources are defined in code, enabling version control
- **CI/CD Integration**: Bundles can be deployed through CI/CD pipelines
- **Environment Consistency**: The same bundle can be deployed to different environments
- **Parameterization**: Variables allow for flexible and reusable bundles
- **Dependency Management**: Dependencies between resources are managed automatically
- **Validation**: Bundles can be validated before deployment
- **Documentation**: Resources are self-documented through code

## Workflow

The typical workflow for working with Databricks Asset Bundles is:

1. **Define**: Define resources in YAML files and associated code
2. **Validate**: Validate the bundle to ensure it's correctly defined
3. **Deploy**: Deploy the bundle to a target environment
4. **Monitor**: Monitor the deployed resources
5. **Update**: Update the bundle as needed and redeploy

## CI/CD Integration

Databricks Asset Bundles can be integrated with CI/CD pipelines, such as GitHub Actions. The DAB ETL Framework includes a GitHub Actions workflow that:

1. Validates the bundle
2. Deploys to the development environment on push to main
3. Deploys to the test environment after successful deployment to development
4. Deploys to the production environment on manual trigger

## Conclusion

Databricks Asset Bundles provide a powerful way to manage Databricks resources as code. By using DAB, the DAB ETL Framework enables version control, CI/CD integration, and consistent deployment across environments.

This approach follows software engineering best practices and makes the ETL pipeline more maintainable, scalable, and reliable.
