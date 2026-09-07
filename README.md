# Azure Volve Data Engineering Project

An end-to-end **7-day Azure data engineering project** built around Equinor's Volve production dataset and EIA Open Data.

The project demonstrates a complete modern data engineering workflow: automated ingestion, lakehouse-style processing, dimensional modeling, SQL serving, BI reporting, security, optimization, and documentation using Microsoft Azure.

## Project Overview

The solution was developed as a focused 7-day build, progressing from raw data ingestion to an analytics-ready Power BI dashboard.

### Architecture

**Equinor Volve / EIA Open Data**  
→ **Azure Synapse Pipelines**  
→ **ADLS Gen2 Bronze**  
→ **Synapse Spark / Silver Delta**  
→ **Gold Star Schema / Delta**  
→ **Synapse Serverless SQL Views**  
→ **Power BI**

Azure Key Vault and Synapse Managed Identity provide secure secret and resource access.

## Technology Stack

- Azure Synapse Analytics
- ADLS Gen2
- Synapse Pipelines
- Apache Spark / PySpark
- Delta Lake
- Azure Key Vault
- Serverless SQL
- Power BI
- DAX

## 7-Day Build

### Day 1 — Bronze Ingestion
- Ingested the Volve daily production dataset.
- Converted the source data to Parquet for downstream processing.
- Established the Bronze layer.

### Day 2 — Automated Ingestion
- Built Synapse Pipelines for data ingestion.
- Integrated the EIA Open Data API.
- Stored the EIA API key securely in Azure Key Vault.
- Configured scheduled EIA ingestion.

### Day 3 — Silver Transformation
- Cleaned and standardized Volve and EIA datasets.
- Applied appropriate data types and naming conventions.
- Preserved legitimate NULL measurements.
- Stored Silver datasets as Delta tables.

### Day 4 — Gold Data Modeling
- Defined the production fact grain as **one well bore × one production date**.
- Built a star schema with production, well, field, and date tables.
- Added cumulative production and decline metrics.
- Partitioned the production fact by year.
- Demonstrated Delta MERGE for incremental loading.

### Day 5 — SQL Serving
- Exposed Gold Delta data through Synapse Serverless SQL.
- Created reusable analytical views.
- Applied column selection and partition filtering for query efficiency.

### Day 6 — Power BI
- Connected Power BI to the Serverless SQL views.
- Built production KPIs and analytical visuals.
- Added production trends, top wells, cumulative production, and filtering.
- Included EIA electricity retail pricing as contextual market information.

### Day 7 — Security, Optimization & Documentation
- Verified Key Vault and Managed Identity configuration.
- Applied Azure RBAC.
- Disabled anonymous blob access.
- Applied Spark and SQL optimization techniques.
- Documented the architecture, data layers, model, and engineering decisions.
- Configured cost monitoring and stopped compute.

## Key Engineering Decisions

- **Bronze:** Parquet for landed analytical copies and reproducible downstream processing.
- **Silver:** Delta Lake for cleaned and standardized datasets.
- **Gold:** Star schema optimized for analytical workloads.
- **Fact grain:** One well bore × one production date.
- **Partitioning:** Production fact partitioned by year.
- **Incremental processing:** Delta MERGE using `production_key`.
- **Security:** EIA credentials stored in Azure Key Vault.
- **Authentication:** Synapse Managed Identity used for Azure resource access.
- **Serving:** Power BI consumes SQL views rather than raw lake files.
- **EIA modeling:** EIA data remains separate because its state × sector × month grain does not safely map to the Volve well × day production grain.

## Security & Cost Practices

The project applies basic production-oriented practices including:

- Azure Key Vault for API secrets
- Managed Identity for Azure resource authentication
- Azure RBAC
- Disabled anonymous blob access
- Cost budget and alerts
- Deallocated Spark compute after processing

No API keys or credentials are included in this repository.

## Outcome

This project demonstrates an end-to-end Azure data engineering workflow from **source ingestion to business-facing analytics**, while applying practical principles around data modeling, incremental processing, security, performance, and cost management.

The accompanying documentation records the implementation decisions, validation results, architecture, and lessons learned throughout the 7-day build.

## Future Production Improvements

Potential next steps include:

- CI/CD
- Git-integrated Synapse development
- Automated data-quality testing
- Pipeline failure notifications
- Fully incremental Silver and Gold processing
- Slowly changing dimensions where required
- Centralized monitoring
- Separate development, test, and production environments
- Private networking and managed private endpoints