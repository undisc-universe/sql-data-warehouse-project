-- 1. Data Quality Checks for silver.crm_cust_info
-- SELECT NULL RECORDS
-- Expected Results: 0 rows
SELECT 
    * 
FROM silver.crm_cust_info
WHERE cst_id IS NULL;

-- Check NULL keys from all crm tables
-- Expected Results: 0 rows
SELECT 
    sd.sls_prd_key,
    sd.sls_cust_id,
    pi.prd_key,
    ci.cst_id
FROM 
    silver.crm_sales_details sd
LEFT JOIN 
    silver.crm_prd_info pi ON sd.sls_prd_key = pi.prd_key
LEFT JOIN
    silver.crm_cust_info ci ON sd.sls_cust_id = ci.cst_id
WHERE 1=1
AND (
    sd.sls_prd_key IS NULL 
    OR sd.sls_cust_id IS NULL 
    OR pi.prd_key IS NULL 
    OR ci.cst_id IS NULL
);


-- DUPLICATES CHECK (Will check NULLs also !):
-- Expected Results: 0 rows
SELECT cst_id, COUNT(*) AS duplicate_records_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;


-- DUPLICATES CHECK (WITH ROW_NUMBER()):
-- IDENTIFY VALID IDs (NO NULLs)
-- Expected Results: 0 rows
WITH ranked_ids AS (
    SELECT
        cst_id,
        cst_create_date AS reference_date,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS rn
    FROM
        silver.crm_cust_info
)
SELECT
    cst_id AS duplicate_ids,
    reference_date
FROM 
    ranked_ids
WHERE 1=1
AND rn > 1
AND cst_id IS NOT NULL
ORDER BY cst_id;


-- Check lead/trailing spaces, whitespace in crm_cust_info
-- Expected Results: 0 rows
SELECT 'cst_id_check' AS column_name, *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(CAST(cst_id AS VARCHAR(20)))) <> LENGTH(CAST(cst_id AS VARCHAR(20)))

UNION ALL

SELECT 'cst_key_check', *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(cst_key)) <> LENGTH(cst_key)
OR cst_key = ''

UNION ALL

SELECT 'cst_firstname_check', *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(cst_firstname)) <> LENGTH(cst_firstname)
OR cst_firstname = ''

UNION ALL

SELECT 'cst_lastname_check', *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(cst_lastname)) <> LENGTH(cst_lastname)
OR cst_lastname = ''

UNION ALL 

SELECT 'cst_mar_status_check', *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(cst_marital_status)) <> LENGTH(cst_marital_status)
OR cst_marital_status = '' 

UNION ALL 

SELECT 'cst_gender_check', *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(cst_gndr)) <> LENGTH(cst_gndr)
OR cst_gndr = ''

UNION ALL 

SELECT 'cst_create_date_check', *
FROM silver.crm_cust_info
WHERE LENGTH(TRIM(CAST(cst_create_date AS VARCHAR(50)))) <> LENGTH(CAST(cst_create_date AS VARCHAR(50)))
OR CAST(cst_create_date AS VARCHAR(50)) = '';

-- Check low cardinality columns
-- Expected Results: 'Not Defined', 'Male' or 'Female'
SELECT DISTINCT cst_gndr FROM silver.crm_cust_info;

-- Expected Results: 'Not Defined', 'Single' or 'Married'
SELECT DISTINCT cst_marital_status FROM silver.crm_cust_info;

-- Check if the number of records in silver is less or equal to the number of records in bronze for crm_cust_info
WITH total_records_silver AS (
SELECT
    MIN(cst_id) AS key,
    COUNT(*) AS total_records_silver
FROM 
    silver.crm_cust_info
),
total_records_bronze AS (
SELECT
    MIN(cst_id) AS key,
    COUNT(*) AS total_records_bronze
FROM
    bronze.crm_cust_info
)
SELECT 
    1 AS is_true,
    total_records_bronze - total_records_silver AS difference
FROM total_records_silver s
LEFT JOIN total_records_bronze b ON s.key = b.key
WHERE total_records_bronze >= total_records_silver;



-- 2. Check for NULLs or Duplicates in Primary Key for silver.crm_prd_info silver table
-- Expected Results: 0 rows

-- DUPLICATES CHECK (Will check NULLs also !):
SELECT prd_id, COUNT(*) AS duplicate_records_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for unwanted spaces in prd info table
SELECT 'prd_nm_check' AS column_to_check, prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm)

UNION ALL 

SELECT 'prd_key_check', prd_key
FROM silver.crm_prd_info
WHERE prd_key <> TRIM(prd_key)

UNION ALL 

SELECT 'prd_line_check', prd_line
FROM silver.crm_prd_info
WHERE prd_line <> TRIM(prd_line);

-- Check for negative or null values for prd_cost
SELECT prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Check for all possible values for low cardinality columns
SELECT DISTINCT prd_line FROM silver.crm_prd_info;

-- Check for Invalid Date Orders
SELECT * 
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Check if the number of records in silver is bigger or equal to the number of records in bronze
--   for crm_prd_info

WITH total_records_silver AS (
SELECT
    MIN(prd_id) AS key,
    COUNT(*) AS total_records_silver
FROM 
    silver.crm_prd_info
),
total_records_bronze AS (
SELECT
    MIN(prd_id) AS key,
    COUNT(*) AS total_records_bronze
FROM
    bronze.crm_prd_info
)
SELECT 
    1 AS is_true, 
    total_records_bronze - total_records_silver AS difference
FROM total_records_silver s
LEFT JOIN total_records_bronze b ON s.key = b.key
WHERE total_records_bronze >= total_records_silver;


-- 3. Data Quality Checks in silver.crm_sales_details

-- Check for unwanted spaces in sls_ord_num column
-- Expected Results: No Results
SELECT * FROM silver.crm_sales_details WHERE LENGTH(sls_ord_num) <> LENGTH(TRIM(sls_ord_num));

-- Check if there are missing sls_prd_key in silver.crm_prd_info prd_key column
-- Expected Results: No Results
SELECT
    DISTINCT sls_prd_key
FROM
    silver.crm_sales_details
WHERE sls_prd_key NOT IN (SELECT DISTINCT prd_key FROM silver.crm_prd_info);

-- Check if there are missing sls_cust_id in silver.crm_cust_info cst_id column
-- Expected Results: No Results
SELECT
    DISTINCT sls_cust_id
FROM
    silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT DISTINCT cst_id FROM silver.crm_cust_info);

-- Check for invalid dates
-- Expected Results: No invalid date integers
SELECT 
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM 
    silver.crm_sales_details
WHERE 1=1
AND (
    LENGTH(CAST(sls_order_dt AS VARCHAR(20))) <> 10
    OR  LENGTH(CAST(sls_ship_dt AS VARCHAR(20))) <> 10
    OR  LENGTH(CAST(sls_due_dt AS VARCHAR(20))) <> 10
    OR  sls_due_dt > '2050-01-01'
    OR  sls_ship_dt > '2050-01-01'
    OR  sls_due_dt > '2050-01-01'
    OR  sls_due_dt < '1900-01-01'
    OR  sls_ship_dt < '1900-01-01'
    OR  sls_due_dt < '1900-01-01'
);

-- Check if Order Date is always before the Shipping Date or Due Date
-- Expected Results: 0 rows
SELECT 
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM 
    silver.crm_sales_details
WHERE 1=1
AND (
    sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt
);

-- Business Rule for Sales, Quantity and Price: No negative values, zeros, or NULLs
-- Rules to improve data quality in case of a bad scenario:
--     1. If sales are negative, zero or null, derive the results using Quantity and Price
--     2. If price is zero or null, calculate it using Sales and Quantity
--     3. If price is negative, convert it to a positive value
-- Check if Sales = Price * Quantity
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
--    CASE 
--        WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales <> sls_quantity * ABS(sls_price)
--        THEN sls_quantity * ABS(sls_price)
--        ELSE sls_sales
--    END AS sls_sales,
--    CASE
--        WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price <> sls_quantity * ABS(sls_price) / sls_quantity
--        THEN sls_sales / sls_quantity
--        ELSE sls_price
--    END AS sls_price
    
FROM 
    silver.crm_sales_details
WHERE 1=1
AND (
    sls_sales <> sls_quantity * sls_price 
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
)
ORDER BY sls_sales DESC, sls_quantity, sls_price;

-- Check if the number of records in silver is bigger or equal to the number of records in bronze
--   for crm_sales_details

WITH total_records_silver AS (
SELECT
    MIN(sls_cust_id) AS key,
    COUNT(*) AS total_records_silver
FROM 
    silver.crm_sales_details
),
total_records_bronze AS (
SELECT
    MIN(sls_cust_id) AS key,
    COUNT(*) AS total_records_bronze
FROM
    bronze.crm_sales_details
)
SELECT 
    1 AS is_true,
    total_records_bronze - total_records_silver AS difference
FROM total_records_silver s
LEFT JOIN total_records_bronze b ON s.key = b.key
WHERE total_records_bronze >= total_records_silver;



-- 4. Data Quality checks for silver.erp_cust_az12
-- Check for invalid keys
-- Expected Results: 0 rows
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    bdate,
    gen
FROM silver.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END LIKE 'NAS%';

-- Check for dates that are in the future
-- Expected Results: 0 rows
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid,
    CASE
        WHEN bdate > NOW() THEN NULL
        ELSE bdate
    END AS bdate,
    gen
FROM silver.erp_cust_az12
WHERE bdate > CURRENT_DATE;


-- Check for low cardinality columns
-- Expected Results: 'Male', 'Female' or 'Not Defined'
SELECT DISTINCT gen FROM (
    SELECT
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        ELSE 'Not Defined'
    END AS gen

    FROM
    silver.erp_cust_az12
);

-- Check if the number of records in silver is bigger or equal to the number of records in bronze
--   for erp_cust_az12
WITH total_records_silver AS (
SELECT
    MIN(cid) AS key,
    COUNT(*) AS total_records_silver
FROM 
    silver.erp_cust_az12
),
total_records_bronze AS (
SELECT
    MIN(CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid)) ELSE cid END) AS key,
    COUNT(*) AS total_records_bronze
FROM
    bronze.erp_cust_az12
)
SELECT 
    1 AS is_true,
    total_records_bronze - total_records_silver AS difference
FROM total_records_silver s
LEFT JOIN total_records_bronze b ON s.key = b.key 
WHERE total_records_bronze >= total_records_silver;



-- 5. Data Quality checks for silver.erp_loc_a101
-- Check if there are cid keys not present in silver.crm_cust_info
-- Expected Results: 0 rows
SELECT
    REPLACE(cid, '-', '') AS cid,
    cntry
FROM
    bronze.erp_loc_a101
WHERE 
    REPLACE(cid, '-', '') NOT IN (SELECT cst_key FROM silver.crm_cust_info); -- table to join erp_loc_a101

-- Check if there are incorrect / values to map
-- Expected Results: NULL or empty/whitespace rows
WITH countries_mapped AS (
SELECT
    cntry,
    CASE 
        WHEN UPPER(TRIM(cntry)) IN ('UNITED STATES', 'USA', 'US') THEN 'United States'
        WHEN UPPER(TRIM(cntry)) IN ('AUSTRALIA', 'AUS') THEN 'Australia'
        WHEN UPPER(TRIM(cntry)) IN ('GERMANY', 'DE') THEN 'Germany'
        WHEN UPPER(TRIM(cntry)) IN ('CANADA', 'CA') THEN 'Canada'
        WHEN UPPER(TRIM(cntry)) IN ('FRANCE', 'FR') THEN 'France'
        WHEN UPPER(TRIM(cntry)) IN ('UNITED KINGDOM', 'UK') THEN 'United Kingdom'
        ELSE 'Not Defined'
    END AS cntry_final
FROM 
    bronze.erp_loc_a101
)
SELECT DISTINCT cntry, cntry_final FROM countries_mapped WHERE cntry_final NOT IN ('United States','Australia','Germany','Canada','France','United Kingdom');

-- Check if the number of records in silver is bigger or equal to the number of records in bronze
--   for erp_loc_a101
WITH total_records_silver AS (
SELECT
    MIN(cid) AS key,
    COUNT(*) AS total_records_silver
FROM 
    silver.erp_loc_a101
),
total_records_bronze AS (
SELECT
    MIN(REPLACE(cid, '-', '')) AS key,
    COUNT(*) AS total_records_bronze
FROM
    bronze.erp_loc_a101
)
SELECT 
    1 AS is_true,
    total_records_bronze - total_records_silver AS difference
FROM total_records_silver s
LEFT JOIN total_records_bronze b ON s.key = b.key 
WHERE total_records_bronze >= total_records_silver;



-- 6. Data Quality Checks in silver.erp_pc_cat_g1v2
-- Check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
where cat <> trim(cat) OR subcat <> trim(subcat) OR maintenance <> trim(maintenance);

-- Check if the number of records in silver is bigger or equal to the number of records in bronze
--   for erp_px_cat_g1v2
WITH total_records_silver AS (
SELECT
    MIN(id) AS key,
    COUNT(*) AS total_records_silver
FROM 
    silver.erp_px_cat_g1v2
),
total_records_bronze AS (
SELECT
    MIN(id) AS key,
    COUNT(*) AS total_records_bronze
FROM
    bronze.erp_px_cat_g1v2
)
SELECT 
    1 AS is_true,
    total_records_bronze - total_records_silver AS difference
FROM total_records_silver s
LEFT JOIN total_records_bronze b ON s.key = b.key 
WHERE total_records_bronze >= total_records_silver;