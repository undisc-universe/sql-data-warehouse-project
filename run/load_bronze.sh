#!/bin/bash
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo ".env file not found"
  exit 1
fi


# 1. Create database & schemas (connect to postgres!)
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_ADMIN" -v ON_ERROR_STOP=1 -f scripts/bronze/init_database.sql

# 2. Create tables
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/bronze/create_tables.sql

# 3. Load data
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/bronze/load_crm.sql
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/bronze/load_erp.sql

# 4. Verify
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f tests/verify_load_counts.sql


# Setup to make load_bronze.sh executable : chmod +x run/load_bronze.sh
# Bronze Pipeline run command : ./run/load_bronze.sh