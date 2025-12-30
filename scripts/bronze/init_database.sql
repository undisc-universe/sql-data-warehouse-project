/*
==========================================================
Create Database and Schemas (PostgreSQL)
==========================================================
WARNING:
    This script DROPS the entire database.
    Run only in development.
*/

-- Terminate active connections
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE datname = 'DataWarehouse'
  AND pid <> pg_backend_pid();

-- Drop & recreate database
DROP DATABASE IF EXISTS "DataWarehouse";
CREATE DATABASE "DataWarehouse";

-- Connect to the new database (psql only)
\c "DataWarehouse"

-- Create schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;
