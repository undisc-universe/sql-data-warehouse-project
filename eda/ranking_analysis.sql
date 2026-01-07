-- Which 5 products generate highest revenue
SELECT
    dp.product_number,
    dp.product_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.product_number, dp.product_name
ORDER BY total_revenue DESC
LIMIT 5

-- What are the 5 worst-performing products in terms of sales ?
SELECT
    dp.product_number,
    dp.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
GROUP BY dp.product_number, dp.product_name
ORDER BY total_sales ASC
LIMIT 5


-- Find the Top-10 customers who have generated the highest revenue
SELECT customer_name, total_sales_by_customer FROM 
(
    SELECT
        CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
        SUM(fs.sales_amount) AS total_sales_by_customer,
        ROW_NUMBER() OVER(ORDER BY SUM(fs.sales_amount) DESC) AS rn
        --RANK() OVER(ORDER BY SUM(fs.sales_amount) DESC) AS rank,
        --DENSE_RANK() OVER(ORDER BY SUM(fs.sales_amount) DESC)
    FROM
        gold.fact_sales fs
    LEFT JOIN
        gold.dim_customers dc ON fs.customer_key = dc.customer_key
    GROUP BY CONCAT(dc.first_name, ' ', dc.last_name)
    ORDER BY total_sales_by_customer DESC
)
WHERE rn <= 10


-- Find the 3 customer with the fewest orders placed
SELECT customer_name, number_of_orders_by_customer FROM
(
    SELECT
        CONCAT(dc.first_name, ' ', dc.last_name) AS customer_name,
        COUNT(DISTINCT fs.order_number) AS number_of_orders_by_customer,
        DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fs.order_number) DESC) AS rank
    FROM
        gold.fact_sales fs
    LEFT JOIN
        gold.dim_customers dc ON fs.customer_key = dc.customer_key
    GROUP BY CONCAT(dc.first_name, ' ', dc.last_name)
    ORDER BY number_of_orders_by_customer ASC 
)
WHERE rank = 13
LIMIT 3
