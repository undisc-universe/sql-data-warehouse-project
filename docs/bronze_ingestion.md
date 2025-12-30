# PostgreSQL Data Warehouse – Bronze Layer Setup (WSL)

## Overview

This project implements a **PostgreSQL-based data warehouse ingestion pipeline** using a **Bronze → Silver → Gold** layered architecture.  
The focus of this setup is the **Bronze layer**, which performs **raw, repeatable bulk ingestion** of CSV source data into PostgreSQL.

The solution is designed to:
- Be **repeatable and idempotent**
- Run **locally on Windows using WSL**
- Follow **PostgreSQL-native best practices**
- Avoid insecure or fragile workarounds

---

## Environment

- **OS**: Windows
- **Windows Subsystem for Linux**: WSL (Ubuntu)
- **Database**: PostgreSQL (running on Windows)
- **Client tools**:
  - `psql` (Linux client inside WSL)
  - Bash scripts
- **Editor**: VS Code
- **Version control**: GiT

---

## High-Level Architecture

CSV Files (Windows filesystem)
↓
WSL (psql client, bash automation)
↓
PostgreSQL (Windows service)
↓
Bronze Schema (raw ingestion)

---

## Key Design Decisions

### 1. Use of `psql` + `\copy`
- `\copy` reads files from the **client filesystem**
- This avoids PostgreSQL server permission issues on Windows
- Allows CSVs to remain in the user's directory
- Enables fast, safe bulk loads

### 2. Separation of Responsibilities
- **Database-level operations** (create/drop database) are isolated
- **Schema/table creation** is separate from data loading
- **Data loading** is script-driven and repeatable

### 3. WSL for Production Parity
- Linux-native tooling (`psql`, bash)
- File access via `/mnt/c`
- Same workflow used in real Linux servers

---

## Directory Structure

sql-data-warehouse-project/
│
├── scripts/
│ ├── init_database.sql # Drop/create DB + schemas (DEV only)
│ ├── create_tables.sql # Bronze table definitions
│ ├── load_crm.sql # CRM CSV ingestion (\copy)
│ ├── load_erp.sql # ERP CSV ingestion (\copy)
│ └── verify_load_counts.sql # Row count validation
│
├── run/
│ └── load_bronze.sh # Bash orchestration script
│
├── datasets/
│ ├── source_crm/
│ └── source_erp/


---

## Database Initialization (`init_database.sql`)

This script:
- Terminates active connections to the target database
- Drops and recreates the `DataWarehouse` database
- Creates the `bronze`, `silver`, and `gold` schemas

> ⚠️ **Development only** — not to run in production

Executed while connected to the `postgres` database.

---

## Table Creation (`create_tables.sql`)

- Drops existing Bronze tables if present
- Recreates all CRM and ERP tables
- Wrapped in a transaction for atomicity

This guarantees a clean schema state before loading data.

---

## Data Loading (`load_crm.sql`, `load_erp.sql`)

- Uses `TRUNCATE` for safe re-runs
- Uses **single-line `\copy` commands** (required by `psql`)
- Loads CSV files from Windows paths via `/mnt/c/...`

Example:

```sql
\copy bronze.crm_cust_info FROM '/mnt/c/Users/.../cust_info.csv' WITH (FORMAT csv, HEADER true)


---

## Database Initialization (`init_database.sql`)

This script:
- Terminates active connections to the target database
- Drops and recreates the `DataWarehouse` database
- Creates the `bronze`, `silver`, and `gold` schemas

> ⚠️ **Development only** — never to be run in production

Executed while connected to the `postgres` database.

---

## Table Creation (`create_tables.sql`)

- Drops existing Bronze tables if present
- Recreates all CRM and ERP tables
- Wrapped in a transaction for atomicity

This guarantees a clean schema state before loading data.

---

## Data Loading (`load_crm.sql`, `load_erp.sql`)

- Uses `TRUNCATE` for safe re-runs
- Uses **single-line `\copy` commands** (required by `psql`)
- Loads CSV files from Windows paths via `/mnt/c/...`

Example:

```sql
\copy bronze.crm_cust_info FROM '/mnt/c/Users/.../cust_info.csv' WITH (FORMAT csv, HEADER true)
