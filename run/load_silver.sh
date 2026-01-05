#!/bin/bash
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo ".env file not found"
  exit 1
fi


# 2. Create Silver tables
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/silver/create_tables.sql

# 3. Load data
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/silver/load_crm.sql
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/silver/load_erp.sql

# 4. Verify
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f tests/check_silver_data_quality.sql


# Setup to make load_bronze.sh executable : chmod +x run/load_silver.sh
# Silver Pipeline run command : ./run/load_silver.sh