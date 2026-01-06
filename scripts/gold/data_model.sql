-- 1. Build Customer's Dimensional Table
CREATE OR REPLACE VIEW gold.dim_customers AS 
SELECT
    ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key, -- Surrogate Key to connect the data model
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_number,
    ci.cst_firstname AS first_name,
    ci.cst_lastname AS last_name,
    CASE 
        WHEN ci.cst_gndr <> 'Not Defined' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'Not Defined') -- Handle NULL values in case there is no match between crm_cust_info and erp_cust_az12
    END AS gender,
    ca.bdate AS birthdate,
    ci.cst_marital_status AS marital_status,
    la.cntry AS country,
    ci.cst_create_date AS create_date
   
FROM 
    silver.crm_cust_info ci
LEFT JOIN
    silver.erp_cust_az12 ca
ON
    ci.cst_key = ca.cid
LEFT JOIN
    silver.erp_loc_a101 la
ON
    ci.cst_key = la.cid;

-- 2. Build Product's Dimensional Table
-- Business Rule: Keep only recent data; if End Date
-- is NULL then it is the current information of the Product

-- Convert the type 2 table into a type with no historical data !
CREATE OR REPLACE VIEW gold.dim_products AS 
SELECT
    ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id AS product_id,
    pn.prd_key AS product_number,
    pn.prd_nm AS product_name,
    pn.cat_id AS category_id,
    pc.cat AS category,
    pc.subcat AS subcategory,
    pc.maintenance,
    pn.prd_cost AS cost,
    pn.prd_line AS product_line,
    pn.prd_start_dt AS start_date 
FROM
    silver.crm_prd_info pn
LEFT JOIN
    silver.erp_px_cat_g1v2 pc
ON
    pn.cat_id = pc.id
WHERE prd_end_dt IS NULL;



-- 3. Build Sales Factual Table
-- 1st Step: Get the surrogate keys from the gold dim tables to connect fact and dim data in the future
CREATE OR REPLACE VIEW gold.fact_sales AS 
SELECT
    -- DIMENSION KEYS
    sls_ord_num AS order_number,
    ct.customer_key,
    pd.product_key,
    -- DATES
    sls_order_dt AS order_date,
    sls_ship_dt AS shipping_date,
    sls_due_dt AS due_date,
    -- MEASURES
    sls_price AS price,
    sls_quantity AS quantity,
    sls_sales AS sales_amount
    
FROM
    silver.crm_sales_details sd
LEFT JOIN 
    gold.dim_customers ct ON sd.sls_cust_id = ct.customer_id
LEFT JOIN
    gold.dim_products pd ON sd.sls_prd_key = pd.product_number