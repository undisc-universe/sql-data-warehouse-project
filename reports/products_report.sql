/*
=============================================================================
Products Report
=============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors

Highlights:
    1. Gather essential fields such as product name, category and subcategory and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
        - total orders;
        - total sales;
        - total quantity sold;
        - total customers;
        - lifespan (in months);
    4. Calculates (in months):
        - recency (months since last order);
        - average order value;
        - average monthly spend;
=============================================================================
*/
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
CREATE OR REPLACE VIEW gold.products_report AS
WITH product_aggregations AS (
SELECT
--- DIMENSIONS ---
    f.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost,

    COUNT(DISTINCT f.order_number) AS total_orders,
    SUM(f.sales_amount) AS total_sales,
    SUM(f.quantity) AS total_quantity,
    COUNT(DISTINCT f.customer_key) AS total_customers,
    MAX(order_date) AS last_order,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
    + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS lifespan,
    ROUND(AVG(CAST(sales_amount AS DECIMAL(38,16)) / NULLIF(f.quantity, 0)), 2) AS avg_selling_price
FROM
    gold.fact_sales f
LEFT JOIN
    gold.dim_products p ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL
GROUP BY
    f.product_key,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    CASE 
        WHEN total_sales < 10000 THEN 'Below 10000'
        WHEN total_sales BETWEEN 10000 AND 50000 THEN '10000 - 50000'
        WHEN cost BETWEEN 50000 AND 750000 THEN '50000 - 750000'
        ELSE 'Above 750000'
    END AS cost_range,
    CASE
        WHEN total_sales < 1000 THEN 'Low Sales Performance'
        WHEN total_sales BETWEEN 10000 AND 50000 THEN 'Mid Sales Performance'
        ELSE 'High Sales Performance'
    END AS sales_performance,
    total_orders,
    total_sales,
    total_quantity,
    avg_selling_price,
    total_customers,
    last_order,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, last_order)) * 12
    + EXTRACT(MONTH FROM AGE(CURRENT_DATE, last_order)) AS recency,
    CASE WHEN total_sales = 0 THEN 0 ELSE total_sales / total_orders END AS average_order_revenue,
    ROUND(total_sales / NULLIF(lifespan, 0), 2) AS average_monthly_revenue,
    lifespan
FROM
    product_aggregations
WHERE product_key = 3