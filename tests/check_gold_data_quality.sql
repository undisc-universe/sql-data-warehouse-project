-- 1. Quality check for gold data model
-- Check if any duplicate IDs were introduced after JOIN logic in the customers information
-- Expected Results: 0 rows

SELECT
    cst_id, COUNT(*) AS duplicate_id_count
FROM
    (
    SELECT
        ci.cst_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM 
        silver.crm_cust_info ci
    LEFT JOIN
        silver.erp_cust_az12 ca
    ON
        ci.cst_key = ca.cid
    LEFT JOIN
        silver.erp_loc_a101 la
    ON
        ci.cst_key = la.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- 1.1 Check which gender column we should keep
-- Business Rule: The Master Source of Customer Data is CRM.
-- Check which rows have different values from each other.
-- Build a transformation to integrate both source system columns into one.

SELECT
    ci.cst_gndr,
    ca.gen,
    CASE 
        WHEN ci.cst_gndr <> 'Not Defined' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'Not Defined') -- Handle NULL values in case there is no match between crm_cust_info and erp_cust_az12
    END AS new_gen
FROM 
    silver.crm_cust_info ci
LEFT JOIN
    silver.erp_cust_az12 ca
ON
    ci.cst_key = ca.cid
WHERE ci.cst_gndr <> ca.gen
ORDER BY 1,2
LIMIT 5;

-- 1.2. Check gold.dim_customers
-- Check uniqueness for gender information
-- Expected Results: 'Male', 'Female' or 'Not Defined'

SELECT DISTINCT gender FROM gold.dim_customers;



-- 2. Check prd_key uniqueness for product's table
-- Expected Results: 0 rows

SELECT
    prd_key, COUNT(*) AS duplicate_row_count
FROM (
    SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pc.cat,
    pc.subcat,
    pc.maintenance
FROM
    silver.crm_prd_info pn
LEFT JOIN
    silver.erp_px_cat_g1v2 pc
ON
    pn.cat_id = pc.id
WHERE prd_end_dt IS NULL
)
GROUP BY prd_key
HAVING COUNT(*) > 1;


-- 3. Fact Sales: Check if all dimension tables can successfully join to our fact table
-- Foreign Key Integrity (Dimensions)
-- Expected Results: 0 rows
SELECT
    fs.order_number
FROM
    gold.fact_sales fs
LEFT JOIN 
    gold.dim_customers dc ON fs.customer_key = dc.customer_key
LEFT JOIN
    gold.dim_products dp ON fs.product_key = dp.product_key
WHERE 1=1
AND dc.customer_key IS NULL OR dp.product_key IS NULL;