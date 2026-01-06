-- Insert Bronze data into silver.erp_cust_az12
\echo ''
\echo '>> Truncating table silver.erp_cust_az12'


TRUNCATE TABLE silver.erp_cust_az12;

\echo '>> Inserting Data into silver.erp_cust_az12'
INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gen
)
SELECT
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))
        ELSE cid
    END AS cid, -- Remove 'NAS' prefix if present
    CASE
        WHEN bdate > NOW() THEN NULL
        ELSE bdate
    END AS bdate, -- Set future birthdates to NULL
    CASE 
        WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
        WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
        ELSE 'Not Defined'
    END AS gen -- Normalize gender values and handle unknown cases or empty spaces
FROM
    bronze.erp_cust_az12;

\echo '>> Load silver.erp_cust_az12 completed'


-- Insert Bronze data into silver.erp_loc_az101
\echo ''
\echo '>> Truncating table silver.erp_loc_a101'

TRUNCATE TABLE silver.erp_loc_a101;

\echo '>> Inserting Data into silver.erp_loc_a101'
INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT
    REPLACE(cid, '-', '') AS cid,
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
    bronze.erp_loc_a101;

\echo '>> Load silver.erp_loc_a101 completed'


-- Insert Bronze data into silver.erp_loc_az101
\echo ''
\echo '>> Truncating table silver.erp_px_cat_g1v2'

TRUNCATE TABLE silver.erp_px_cat_g1v2;

\echo '>> Inserting Data into silver.erp_px_cat_g1v2'
INSERT INTO silver.erp_px_cat_g1v2 (
    id,
    cat,
    subcat,
    maintenance
)
SELECT
    id,
    cat,
    subcat,
    maintenance
FROM
    bronze.erp_px_cat_g1v2;

\echo '>> Load silver.erp_px_cat_g1v2 completed'
\echo ''