-- Change-Over-Time Analysis
-- Formula: ∑[Measure] By [Date Dimension]

-- Changes Over Years: Gives high-level overview insights that helps with strategic decision-making.
SELECT
    date_part('year', order_date) AS date_year,
    date_part('month', order_date) AS date_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY EXTRACT(year from order_date), date_part('month', order_date)
ORDER BY date_year DESC, date_month ASC



-- Cumulative Analysis: Aggregate the data progressively over the time
-- Helps to understand whether our business is growing or declining
-- Formula: ∑[Cumulative Measure] By [Date Dimension]

SELECT
    date_year,
    total_sales AS sales_amount_by_year,
    ROUND(CAST(total_sales AS DECIMAL(38,16)) / CAST(LAG(total_sales, 1, NULL) OVER(ORDER BY date_year ASC) AS DECIMAL(38,16)), 5) AS growth_factor,
    CAST(( (CAST(total_sales AS DECIMAL(38,16)) - CAST(LAG(total_sales, 1, NULL) OVER(ORDER BY date_year ASC) AS DECIMAL(38,16))) 
        /
        CAST(LAG(total_sales, 1, NULL) OVER(ORDER BY date_year ASC) AS DECIMAL(38,16)) *100) AS DECIMAL(38,2)) AS growth_rate, -- performance analysis

    SUM(total_sales) OVER() AS total_gross_revenue,
    
    ROUND(total_sales / SUM(total_sales) OVER() * 100, 2) AS sales_percentage_contribution_to_gross_revenue,
    SUM(total_sales) OVER(ORDER BY date_year ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
    AVG(avg_price) OVER(ORDER BY date_year ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_average_price,
FROM (
    SELECT 
        date_part('year', order_date) AS date_year,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY date_part('year', order_date)
)

-- Growth Rate Year-Over-Year: 2010 -> 2011
-- "Sales increased by ~16.2 thousand percent year over year"
-- "Sales grew by a factor of ~163x"
-- "Sales increased from 43k to 7.1M year over year"


-- Performance Analysis: Comparing the current value to a target value.
-- Current[Measure] - Target[Measure]

/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */
SELECT
    date_year,
    product_name,
    current_sales,
    LAG(current_sales, 1, NULL) OVER(PARTITION BY product_name ORDER BY date_year ASC) AS previous_year_sales,
    ROUND(AVG(current_sales) OVER(PARTITION BY product_name), 0) AS product_avg_sales,
    ROUND(current_sales - AVG(current_sales) OVER(PARTITION BY product_name), 0) AS sales_average_performance,
    CASE
        WHEN ROUND(current_sales - AVG(current_sales) OVER(PARTITION BY product_name), 0) > 0 THEN 'Above Average'
        WHEN ROUND(current_sales - AVG(current_sales) OVER(PARTITION BY product_name), 0) < 0 THEN 'Below Average'
        ELSE 'Average'
    END AS avg_performance_indicator,
    ROUND(CAST(current_sales AS DECIMAL(38,16)) / CAST(LAG(current_sales, 1, NULL) OVER(PARTITION BY product_name ORDER BY date_year ASC) AS DECIMAL(38,16)), 5) AS growth_factor
FROM (
    SELECT
        date_part('year', fs.order_date) AS date_year,
        dp.product_name AS product_name,
        SUM(fs.sales_amount) AS current_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
    WHERE fs.order_date IS NOT NULL
    GROUP BY date_part('year', fs.order_date), dp.product_name
)
WHERE product_name = 'All-Purpose Bike Stand'
ORDER BY product_name, date_year



-- Part-To-Whole Analysis: Analyze how an individual part is performing compared to the overall.
-- ([Measure] / Total[Measure]) * 100 By [Dimension]
SELECT 
    product_category,
    SUM(total_sales) OVER() AS gross_revenue,
    total_sales,
    CONCAT(ROUND(( total_sales / SUM(total_sales) OVER()) * 100, 2), '%') AS category_percent_contribution
FROM (
    SELECT
        dp.category AS product_category,
        SUM(fs.sales_amount) AS total_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key
    GROUP BY dp.category
)


-- Segmentation Analysis: Group the data based on a specific range
-- Helps understand the correlation between two measures
-- [Measure] By [Measure]


-- Segment products into cost ranges and count how many products fall into
-- each segment
SELECT
    cost_range,
    COUNT(product_key) AS number_of_products
FROM (
    SELECT
        product_key,
        product_name,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100 - 500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500 - 1000'
            ELSE 'Above 1000'
        END AS cost_range,
        cost
    FROM gold.dim_products
)
GROUP BY cost_range
ORDER BY number_of_products DESC


-- Group customers into three segments based on their spending behavior:
--  VIP : At least 12 months of history and spending more than 5000€;
--  Regular : At least 12 months of history but spending 5000€ or less;
--  New : lifespan less than 12 months

-- Final objective: Find the total number of customers by each group

WITH measures_calculation AS (
SELECT 
    fs.customer_key,
    EXTRACT(YEAR FROM AGE(MAX(order_date), MIN(order_date))) * 12
  + EXTRACT(MONTH FROM AGE(MAX(order_date), MIN(order_date))) AS customer_lifespan_in_months,
  SUM(sales_amount) AS total_sales_by_customer
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
WHERE 1=1
AND fs.order_date IS NOT NULL
GROUP BY fs.customer_key
),
convert_measures_to_dims AS (
    SELECT
        customer_key,
        CASE
            WHEN customer_lifespan_in_months >= 12 AND total_sales_by_customer > 5000 THEN 'VIP'
            WHEN customer_lifespan_in_months >= 12 AND total_sales_by_customer <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_type 
    FROM measures_calculation
)
SELECT 
    customer_type,
    COUNT(customer_key) AS number_of_customers
FROM convert_measures_to_dims
GROUP BY customer_type
ORDER BY number_of_customers DESC