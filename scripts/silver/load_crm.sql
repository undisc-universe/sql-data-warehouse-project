-- Insert Silver data into crm_cust_info table
\echo ''
\echo '>> Truncating table silver.crm_cust_info'

TRUNCATE TABLE silver.crm_cust_info;

\echo '>> Inserting Data into silver.crm_cust_info'
INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
WITH get_last_records AS (
SELECT
    *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS last_record
FROM
    bronze.crm_cust_info
)
SELECT 
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_firstname,
    CASE UPPER(TRIM(cst_marital_status))
        WHEN 'M' THEN 'Married' 
        WHEN 'S' THEN 'Single'
        ELSE 'Not Defined'
    END AS cst_marital_status, -- Normalize marital status values to readable format
    CASE UPPER(TRIM(cst_gndr))
        WHEN 'M' THEN 'Male' 
        WHEN 'F' THEN 'Female'
        ELSE 'Not Defined'
    END AS cst_gndr, -- Normalize gender values to readable format
    cst_create_date
FROM get_last_records 
WHERE last_record = 1 AND cst_id IS NOT NULL; -- Select the most up-to-date record per customer and eliminate NULL values.


\echo '>> Load silver.crm_cust_info completed'


-- Insert Silver data into crm_prd_info table
\echo ''
\echo '>> Truncating table silver.crm_prd_info'

TRUNCATE TABLE silver.crm_prd_info;


\echo '>> Inserting Data into silver.crm_prd_info'
INSERT INTO silver.crm_prd_info (
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
)
SELECT
    prd_id,
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_')  AS cat_id, -- Extract category ID
    SUBSTRING(prd_key, 7, LENGTH(prd_key))  AS prd_key,  -- Extract real product key
    prd_nm,
    COALESCE(prd_cost, 0) AS prd_cost, -- If business allows, replace NULLs with 0 for prodcut costs
    CASE UPPER(TRIM(prd_line))
        WHEN 'M' THEN 'Mountain'
        WHEN 'R' THEN 'Road'
        WHEN 'S' THEN 'Other Sales'
        WHEN 'T' THEN 'Touring'
        ELSE 'Not Defined'
    END AS prd_line, -- Map product line codes to descriptive values
    prd_start_dt,
    LEAD(prd_start_dt - 1, 1, NULL) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS prd_end_dt -- Calculate end date as one day before the next product start date
FROM
    bronze.crm_prd_info;

\echo '>> Load silver.crm_prd_info completed'


-- Insert Silver data into crm_sales_details
\echo ''
\echo '>> Truncating table silver.crm_sales_details'

TRUNCATE TABLE silver.crm_sales_details;

\echo '>> Inserting Data into silver.crm_sales_details'
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price 
)
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR(25))) <> 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR(25)) AS DATE)
    END AS sls_order_dt,
    CAST(CAST(sls_ship_dt AS VARCHAR(25)) AS DATE),
    CAST(CAST(sls_due_dt AS VARCHAR(25)) AS DATE),
    CASE 
        WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales <> sls_quantity * ABS(sls_price)
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    sls_quantity,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price <> sls_quantity * ABS(sls_price) / sls_quantity
        THEN sls_sales / sls_quantity
        ELSE sls_price
    END AS sls_price

FROM
    bronze.crm_sales_details;

\echo '>> Load silver.crm_sales_details completed'