# Volve Data Engineering Project

## Overview

Built an end-to-end Azure data engineering solution using Equinor Volve production data and EIA Open Data.

## Architecture

Equinor Volve / EIA Open Data
→ Azure Synapse Pipelines
→ ADLS Gen2 Bronze
→ Synapse Spark Silver
→ Gold Star Schema
→ Serverless SQL Views
→ Power BI

## Technologies

- Azure Synapse Analytics
- ADLS Gen2
- Synapse Pipelines
- Apache Spark / PySpark
- Delta Lake
- Azure Key Vault
- Serverless SQL
- Power BI
- DAX

## Key Engineering Decisions

1. Bronze stores landed source data in its original format where available, with Parquet used for downstream ingestion.
2. Silver and Gold use Delta Lake for reliable analytical processing and incremental updates.
3. Gold is modeled as a star schema.
4. Fact grain is one well bore × one production date.
5. The Gold fact is partitioned by production year.
6. Delta MERGE is used to support repeat and incremental fact loads.
7. EIA data is maintained separately because its state × sector × month grain does not safely map to the Volve well × day grain.
8. Secrets are stored in Azure Key Vault rather than pipeline code.
9. Synapse Managed Identity is used for authentication to Azure resources such as ADLS and Key Vault.
10. Power BI consumes Serverless SQL views rather than raw lake files.

## Security

- EIA API key stored in Azure Key Vault.
- Synapse Managed Identity retrieves the secret from Key Vault.
- ADLS anonymous blob access disabled.
- Azure RBAC used for resource access.
- API credentials are not stored in pipeline source configuration.

## Analytics

The Power BI dashboard provides:

- Total oil production
- Average daily oil rate
- Cumulative oil production
- Average oil change/decline
- Top producing wells
- Production trends
- Well and year filtering
- EIA electricity retail pricing as contextual market information

## Optimization

### Spark

- Partition filtering
- Column pruning

### SQL

- Partition pruning
- Selecting only required columns

## Production Improvements

For a production deployment, the next improvements would include:

- CI/CD
- Git integration
- Automated data-quality testing
- Pipeline failure notifications
- Incremental Silver and Gold processing
- Slowly changing dimensions where required
- Centralized monitoring
- Dev/test/prod environment separation
- Private networking and managed private endpoints