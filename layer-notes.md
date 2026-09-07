# Data Layer Notes

## Bronze

**Purpose:** Raw and reproducible landing layer.

- Volve source data is retained in its landed Excel format.
- A Parquet representation is created for downstream processing.
- EIA API responses are landed as Parquet.
- Transformations are intentionally minimal.
- The layer provides a reproducible starting point for Silver processing.

**Storage:** Parquet

---

## Silver

**Purpose:** Clean, standardized analytical data.

- Standardized column names to `snake_case`.
- Applied appropriate data types.
- Converted dates to analytical date values.
- Trimmed and standardized text fields.
- Standardized categorical values where appropriate.
- Removed duplicate records.
- Preserved legitimate measurement `NULL` values.
- Removed API/request metadata and sensitive API information from the EIA dataset.

**Storage:** Delta Lake

**Main datasets:**

- `silver/production`
- `silver/eia_retail_sales`

---

## Gold

**Purpose:** Business- and analytics-ready data model.

The production model follows a star-schema design:

- `fact_production`
- `dim_well`
- `dim_field`
- `dim_date`

**Fact grain:** One well bore × one production date.

**Characteristics:**

- Delta Lake
- Surrogate dimension keys
- Production fact partitioned by year
- Cumulative production measures
- Oil decline/change metric
- Delta MERGE support for repeat and incremental loads

EIA data remains separate because its state × sector × month grain does not safely map to the Volve well × day production grain.

---

## SQL Serving

**Purpose:** Provide a stable SQL interface for analytics tools.

- Azure Synapse Serverless SQL
- `OPENROWSET(FORMAT='DELTA')`
- Reusable SQL views
- Gold data exposed through views rather than direct Power BI access to lake files
- Queries optimized through column selection and partition filtering where applicable

**Main views:**

- `v_production`
- `v_well`
- `v_field`
- `v_date`
- `v_market`

---

## Power BI

**Purpose:** Provide the business-facing analytics layer.

The dashboard includes:

- Production KPI cards
- Production trends
- Top producing wells
- Cumulative production
- Well and year filtering
- EIA electricity retail pricing as contextual market information

Power BI connects to the Synapse Serverless SQL views rather than directly consuming raw or Silver lake data.