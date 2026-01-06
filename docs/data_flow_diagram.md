## Data Flow Diagram

This diagram illustrates how data flows from **source systems** through the **Bronze**, **Silver**, and **Gold** layers, ultimately forming an analytics-ready **star schema**.

![Data Flow Diagram](diagrams/DATA_FLOW_DIAGRAM.drawio.svg)

> The diagram shows how raw CRM and ERP data is ingested, cleansed, enriched, and modeled for analytical consumption.

---

## Source Systems

### CRM
The CRM system provides customer, product, and sales transactional data.

**Primary datasets:**
- `crm_sales_details`
- `crm_cust_info`
- `crm_prd_info`

### ERP
The ERP system provides supplemental customer, location, and product classification data.

**Primary datasets:**
- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

---

## Bronze Layer (Raw Ingestion)

The Bronze Layer stores **raw, source-aligned data** ingested from CRM and ERP systems.

**Characteristics:**
- No transformations or business rules applied
- Schema closely matches source systems
- Acts as a historical landing zone

**Bronze Tables:**
- `crm_sales_details`
- `crm_cust_info`
- `crm_prd_info`
- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

Each dataset flows independently into the Silver Layer for cleansing and standardization.

---

## Silver Layer (Cleansed & Conformed)

The Silver Layer contains **trusted, standardized datasets** derived from Bronze.

**Key Responsibilities:**
- Data cleansing and normalization
- Key standardization
- Basic enrichment across domains
- Still source-oriented but analytics-safe

**Silver Tables:**
- `crm_sales_details`
- `crm_cust_info`
- `crm_prd_info`
- `erp_cust_az12`
- `erp_loc_a101`
- `erp_px_cat_g1v2`

These tables serve as the **foundation for dimensional modeling** in the Gold Layer.

---

## Gold Layer (Business-Ready Star Schema)

The Gold Layer presents **analytics-ready dimensional models** designed for BI tools and reporting.

### Dimensions

#### `dim_customers`
Built by combining customer data from CRM and ERP sources:
- CRM customer master data
- ERP demographic attributes
- ERP geographic attributes

This creates a single, enriched customer dimension with a surrogate key.

#### `dim_products`
Built by combining:
- CRM product master data
- ERP product category and subcategory data

Only **active products** are included to simplify analysis.

---

### Fact Table

#### `fact_sales`
Built from CRM sales transactions and linked to dimensions using surrogate keys.

**Links:**
- `customer_key` → `dim_customers`
- `product_key` → `dim_products`

**Grain:**
> One row per sales order line item per product per customer.

---

## End-to-End Data Flow Summary

```text
CRM / ERP Sources
       │
       ▼
Bronze Layer (Raw)
       │
       ▼
Silver Layer (Cleansed & Conformed)
       │
       ▼
Gold Layer (Star Schema)
   ├── dim_customers
   ├── dim_products
   └── fact_sales
