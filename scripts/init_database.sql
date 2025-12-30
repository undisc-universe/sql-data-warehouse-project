/*
==========================================================
Create Database and Schemas (PostgreSQL)
==========================================================
Script Purpose:
    - Drops and recreates the 'DataWarehouse' database
    - Creates schemas: bronze, silver, gold

WARNING:
    This script DROPS the entire database.
    All data will be permanently deleted.
    Run only if you are sure.
*/

-- IMPORTANT:
-- You must be connected to a DIFFERENT database (usually 'postgres')
-- before running this script.

-- Terminate existing connections
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'DataWarehouse'
  AND pid <> pg_backend_pid();

-- Drop database if it exists
DROP DATABASE IF EXISTS "DataWarehouse";

-- Create database
CREATE DATABASE "DataWarehouse";

-- Connect to the new database (psql-only command)
-- If using VS Code or pgAdmin, reconnect manually to DataWarehouse
-- \c "DataWarehouse"

-- Create schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
