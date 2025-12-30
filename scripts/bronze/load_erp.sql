\echo 'Loading ERP tables...'

TRUNCATE TABLE bronze.erp_cust_az12;
\copy bronze.erp_cust_az12 FROM '/mnt/c/Users/PedroGon/Downloads/sql-data-warehouse-project (1)/sql-data-warehouse-project/datasets/source_erp/cust_az12.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.erp_loc_a101;
\copy bronze.erp_loc_a101 FROM '/mnt/c/Users/PedroGon/Downloads/sql-data-warehouse-project (1)/sql-data-warehouse-project/datasets/source_erp/loc_a101.csv' WITH (FORMAT csv, HEADER true);

TRUNCATE TABLE bronze.erp_px_cat_g1v2;
\copy bronze.erp_px_cat_g1v2 FROM '/mnt/c/Users/PedroGon/Downloads/sql-data-warehouse-project (1)/sql-data-warehouse-project/datasets/source_erp/px_cat_g1v2.csv' WITH (FORMAT csv, HEADER true);
