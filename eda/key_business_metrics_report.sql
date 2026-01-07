-- Generate a Report that shows all key metrics of the business

SELECT 'total_sales' AS measure, SUM(sales_amount) AS totals FROM gold.fact_sales
UNION ALL
SELECT 'total_quanitty', SUM(quantity) FROM gold.fact_sales
UNION ALL
SELECT 'average_price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'number_of_orders', COUNT(DISTINCT order_number) FROM gold.fact_sales
UNION ALL 
SELECT 'number_of_products', COUNT(DISTINCT product_key) FROM gold.fact_sales
UNION ALL
SELECT 'number_of_customers', COUNT(customer_key) FROM gold.dim_customers
UNION ALL 
SELECT 'number_of_customers_that_placed_an_order', COUNT(DISTINCT customer_key) FROM gold.fact_sales;