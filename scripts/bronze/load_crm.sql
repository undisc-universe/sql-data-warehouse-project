\echo 'Loading CRM tables...'

TRUNCATE TABLE bronze.crm_cust_info;
\copy bronze.crm_cust_info FROM '/mnt/c/Users/PedroGon/Downloads/sql-data-warehouse-project (1)/sql-data-warehouse-project/datasets/source_crm/cust_info.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.crm_prd_info;
\copy bronze.crm_prd_info FROM '/mnt/c/Users/PedroGon/Downloads/sql-data-warehouse-project (1)/sql-data-warehouse-project/datasets/source_crm/prd_info.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.crm_sales_details;
\copy bronze.crm_sales_details FROM '/mnt/c/Users/PedroGon/Downloads/sql-data-warehouse-project (1)/sql-data-warehouse-project/datasets/source_crm/sales_details.csv' WITH (FORMAT csv, HEADER true);
