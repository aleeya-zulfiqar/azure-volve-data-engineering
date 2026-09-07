-- test reading gold data

SELECT TOP 10 *
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/gold/fact_production/',
    FORMAT = 'DELTA'
) AS r;


SELECT
    COUNT(*) AS total_rows,
    COUNT(oil_volume) AS oil_rows,
    COUNT(gas_volume) AS gas_rows,
    COUNT(water_volume) AS water_rows
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/gold/fact_production/',
    FORMAT = 'DELTA'
) AS r;


-- create SQL database

CREATE DATABASE volve_analytics;

USE volve_analytics;


-- create view of main production fact

CREATE VIEW v_production AS
SELECT
    production_key,
    well_key,
    field_key,
    date_key,
    production_date,
    year,
    on_stream_hours,
    avg_downhole_pressure,
    avg_downhole_temperature,
    avg_dp_tubing,
    avg_annulus_pressure,
    avg_choke_size,
    avg_whp,
    avg_wht,
    dp_choke_size,
    oil_volume,
    gas_volume,
    water_volume,
    water_injection_volume,
    cumulative_oil_volume,
    cumulative_gas_volume,
    oil_decline_rate
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/gold/fact_production/',
    FORMAT = 'DELTA'
) AS r;



-- create view of well dimension

CREATE VIEW v_well AS
SELECT
    well_key,
    well_bore_id,
    well_bore_code,
    well_name,
    well_type,
    facility_id,
    facility_name
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/gold/dim_well/',
    FORMAT = 'DELTA'
) AS r;



-- create view of field dimension

CREATE VIEW v_field AS
SELECT
    field_key,
    field_id,
    field_name
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/gold/dim_field/',
    FORMAT = 'DELTA'
) AS r;



-- create view of date dimension

CREATE VIEW v_date AS
SELECT
    date_key,
    date,
    year,
    month,
    month_name,
    quarter,
    day_of_month
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/gold/dim_date/',
    FORMAT = 'DELTA'
) AS r;



-- create view of EIA silver market data

CREATE VIEW v_market AS
SELECT
    period,
    stateid,
    state_name,
    sectorid,
    sector_name,
    revenue,
    sales,
    price,
    customers,
    frequency
FROM OPENROWSET(
    BULK 'https://volvedatalake.dfs.core.windows.net/data/silver/eia_retail_sales/',
    FORMAT = 'DELTA'
) AS r;


-- test views

SELECT TOP 5 * FROM v_production;

SELECT TOP 5 * FROM v_well;

SELECT TOP 5 * FROM v_field;

SELECT TOP 5 * FROM v_date;

SELECT TOP 5 * FROM v_market;




-- which wells produce the most oil overall?

SELECT TOP 5
    w.well_name,
    w.well_bore_id,
    SUM(p.oil_volume) AS total_oil_volume
FROM v_production p
JOIN v_well w
    ON p.well_key = w.well_key
GROUP BY
    w.well_name,
    w.well_bore_id
ORDER BY total_oil_volume DESC;


-- daily production / production history of highest producing well / decline curve

SELECT TOP 1
    w.well_key,
    w.well_name
FROM v_production p
JOIN v_well w
    ON p.well_key = w.well_key
GROUP BY
    w.well_key,
    w.well_name
ORDER BY SUM(p.oil_volume) DESC;

SELECT
    p.production_date,
    p.oil_volume,
    p.cumulative_oil_volume,
    p.oil_decline_rate
FROM v_production p
WHERE p.well_key = 2
ORDER BY p.production_date;



-- how did overall production change year by year?

SELECT
    year,
    SUM(oil_volume) AS total_oil,
    SUM(gas_volume) AS total_gas,
    SUM(water_volume) AS total_water
FROM v_production
GROUP BY year
ORDER BY year;


-- inspect market context via EIA view

SELECT TOP 20
    period,
    state_name,
    sector_name,
    price,
    sales,
    customers
FROM v_market
WHERE price IS NOT NULL
ORDER BY period DESC;


-- partition pruning / optimization

SELECT
    production_date,
    well_key,
    oil_volume,
    gas_volume
FROM v_production
WHERE year = 2015;



-- results validation

SELECT 'v_production' AS view_name, COUNT(*) AS row_count
FROM v_production

UNION ALL

SELECT 'v_well', COUNT(*)
FROM v_well

UNION ALL

SELECT 'v_field', COUNT(*)
FROM v_field

UNION ALL

SELECT 'v_date', COUNT(*)
FROM v_date

UNION ALL

SELECT 'v_market', COUNT(*)
FROM v_market;



-- optimized query

SELECT
    production_date,
    well_key,
    oil_volume,
    gas_volume
FROM v_production
WHERE year = 2015;