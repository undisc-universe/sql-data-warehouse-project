#!/bin/bash
set -e

# Load environment variables
if [ -f .env ]; then
  source .env
else
  echo ".env file not found"
  exit 1
fi


# 1. Create Gold Layer Views
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f scripts/gold/data_model.sql

# 2. Data Quality check
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_DW" -v ON_ERROR_STOP=1 -f tests/check_gold_data_quality.sql


# Setup to make load_bronze.sh executable : chmod +x run/load_gold.sh
# Gold Pipeline run command : ./run/load_gold.sh