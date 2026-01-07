-- Explore objects in the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE table_schema IN ('bronze', 'silver', 'gold');


-- Explore all columns in the Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'dim_customers';


-- Count the number of tables per schema
SELECT table_schema, COUNT(DISTINCT table_name) AS table_count FROM INFORMATION_SCHEMA.TABLES 
WHERE table_schema IN ('bronze', 'silver', 'gold') 
GROUP BY table_schema
ORDER BY table_schema ASC;