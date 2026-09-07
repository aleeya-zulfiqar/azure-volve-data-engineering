# Project Journal

## Day 1 — Bronze Ingestion

**Source:**  
Equinor Volve production dataset

**Source format:**  
Excel (`.xlsx`)

**Source sheet:**  
Daily Production Data

**Rows:**  
15,634

**Columns:**  
24

**Raw landing:**  
`bronze/volve/raw/`

**Parquet location:**  
`bronze/volve/parquet/production/`

**Processing engine:**  
Azure Synapse Spark

**Architecture:**  
Source Excel → Bronze Raw → Spark → Bronze Parquet

**Journal entry:**

The Volve daily production dataset was landed in the Bronze layer and converted to Parquet for analytical processing. Bronze intentionally applies minimal transformation so downstream processing remains traceable to the landed source data.

---

## Day 2 — Automated Ingestion with Synapse Pipelines

**Volve ingestion:**

1. Created the Volve ingestion pipeline.
2. Added a Copy Activity.
3. Configured the source as the landed Volve Excel file.
4. Configured the sink as Parquet in ADLS Gen2.

**EIA ingestion and security:**

1. Obtained and manually tested an EIA API key.
2. Created Azure Key Vault.
3. Stored the EIA API key as a Key Vault secret.
4. Assigned Key Vault Secrets Officer to the development identity.
5. Assigned Key Vault Secrets User to the Synapse workspace Managed Identity.
6. Created the Key Vault linked service.
7. Created the EIA REST linked service.
8. Created the EIA REST dataset.
9. Created the Bronze Parquet sink dataset.
10. Created the EIA ingestion pipeline.
11. Configured the Copy Activity to retrieve EIA API data and land it in dated Bronze Parquet folders.
12. Added a daily schedule trigger.
13. Published the pipeline.

**Result:**  
Both ingestion paths were automated through Synapse Pipelines, with the EIA API secret managed through Azure Key Vault.

---

## Day 3 — Bronze → Silver

### Volve

- Bronze rows: 15,634
- Silver rows: 15,634
- Rows removed: 0
- Columns: 24
- Converted production timestamp to date
- Standardized column names to `snake_case`
- Trimmed text fields
- Standardized categorical text to uppercase
- Retained legitimate measurement `NULL` values rather than converting them to zero
- Stored as Silver Delta at `silver/production`

### EIA

- Bronze rows: 113,832
- Silver rows: 113,832
- Rows removed: 0
- Columns: 14
- Flattened `response.data` into tabular records
- Converted `period` to date
- Cast `revenue`, `sales`, and `price` to `double`
- Cast `customers` to `long`
- Standardized state and sector column names
- Removed API/request metadata and the API key
- Retained legitimate `NULL` measurements
- Stored as Silver Delta at `silver/eia_retail_sales`

**Key learning:**  
Bronze preserves landed source data, while Silver applies structural, type, naming, and data-quality transformations so downstream analytics can reliably consume the data.

---

## Day 4 — Silver → Gold Data Model

### Grain

The production fact grain was defined as:

**One well bore × one production date**

Validation confirmed:

- 15,634 production records
- No duplicate `(well_bore_id, prod_date)` combinations
- Date range: 2007-09-01 to 2016-12-01
- Field: VOLVE
- Oil, gas, water, and water injection are stored as separate measures

### Gold Model

Built the following Delta tables:

- `fact_production`
- `dim_well`
- `dim_field`
- `dim_date`

The dimensions use surrogate keys, and the production fact references the applicable dimension keys.

### Derived Measures

Added:

- `cumulative_oil_volume`
- `cumulative_gas_volume`
- `oil_decline_rate`

### Incremental Loading

- Gold fact stored as partitioned Delta.
- Fact partitioned by production year.
- `production_key` used as the MERGE key.
- MERGE was tested to verify repeat/incremental loading without creating duplicate records.

### EIA Modeling Decision

EIA data was maintained separately because its grain is **state × sector × month**, while Volve production is **well × day**. A direct join would not have a defensible relationship and could introduce row multiplication or incorrect analytical totals.

---

## Day 5 — SQL Serving Layer

Created Serverless SQL views:

| View | Purpose |
|---|---|
| `v_production` | Daily production fact for analytics |
| `v_well` | Well descriptive information |
| `v_field` | Field descriptive information |
| `v_date` | Calendar attributes for time analysis |
| `v_market` | EIA monthly electricity retail-price context |

The Serverless SQL layer reads Gold Delta data from ADLS using `OPENROWSET(FORMAT='DELTA')`.

Reusable views provide a stable interface for analytics tools such as Power BI.

**Optimization:**  
Production queries select only required columns and filter on the Gold fact's `year` partition where applicable, reducing unnecessary data scanned.

---

## Day 6 — Power BI Dashboard

Connected Power BI Desktop to the Synapse Serverless SQL views using Import mode.

Built a dimensional model with:

- `fact_production`
- `dim_well`
- `dim_field`
- `dim_date`
- `market`

Created relationships from the well, field, and date dimensions to the production fact.

Created DAX measures for:

- Total oil production
- Total gas production
- Average daily oil rate
- Cumulative oil production
- Average oil change/decline

Built dashboard visuals for:

- Production KPIs
- Production trends
- Top producing wells
- Cumulative production
- Well and year filtering
- EIA electricity retail pricing as contextual market information

The EIA pricing data is not treated as the realized price of Volve oil production because the ingested EIA dataset represents electricity retail pricing.

---

## Day 7 — Security, Optimization and Documentation

### Security

1. Verified the EIA API key is stored in Azure Key Vault.
2. Verified the Key Vault linked service uses Managed Identity.
3. Verified the actual API key is not exposed in pipeline configuration.
4. Verified the Synapse workspace Managed Identity has the required ADLS RBAC permissions.
5. Disabled anonymous blob access on the storage account.

The authentication flow is:

EIA API Key  
↓  
Azure Key Vault  
↓  
Synapse Managed Identity  
↓  
EIA ingestion configuration  
↓  
Synapse Pipeline

The Managed Identity provides Azure resource authentication; the EIA API itself continues to authenticate using the EIA API key.

### Optimization

Applied:

- Spark partition filtering and column pruning.
- SQL partition pruning and column selection.

### Documentation

Prepared:

- Architecture diagram
- Star-schema diagram
- Layer notes
- Project journal
- Project summary

### Cost Management

Configured project budget and cost alerts.

### Compute

Stopped/deallocated Spark compute after processing.

### Cleanup

Final Azure resource cleanup should be performed after all project artefacts have been backed up and reviewed.