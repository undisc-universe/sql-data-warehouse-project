# Data Dictionary for Gold Layer

## Overview

The Gold Layer represents the **business-level data model**, designed to support analytical and reporting use cases.  
It contains **dimension tables** and **fact tables** that expose clean, conformed, and analytics-ready data derived from the Silver Layer.

---

## 1. gold.dim_customers

**Purpose:**  
Stores customer details enriched with demographic and geographic attributes. This dimension provides a single, unified view of customer information for analytical reporting.

### Columns

| Column Name      | Data Type       | Description |
|------------------|-----------------|-------------|
| customer_key     | INT             | Surrogate key uniquely identifying each customer record in the dimension table. |
| customer_id      | INT             | Unique numerical identifier assigned to each customer from the source system. |
| customer_number  | VARCHAR(50)     | Alphanumeric business identifier representing the customer, used for tracking and referencing. |
| first_name       | VARCHAR(50)     | The customer's first name as recorded in the system. |
| last_name        | VARCHAR(50)     | The customer's last name or family name. |
| gender           | VARCHAR(50)     | The gender of the customer. Derived from CRM data when available; otherwise sourced from ERP data. Defaults to `Not Defined` when unavailable. |
| birthdate        | DATE            | The customer's date of birth, sourced from ERP demographic data. |
| marital_status   | VARCHAR(50)     | The marital status of the customer (e.g., `Married`, `Single`). |
| country          | VARCHAR(50)     | The country of residence for the customer (e.g., `Australia`). |
| create_date      | DATE            | The date when the customer record was created in the CRM system. |

---

## 2. gold.dim_products

**Purpose:**  
Provides detailed information about products and their attributes. This dimension exposes the **current (active) state** of products, with historical records removed to simplify analytics.

**Business Rule:**  
Only records where the product end date is `NULL` are retained, ensuring that the table represents the most recent version of each product.

### Columns

| Column Name        | Data Type       | Description |
|-------------------|-----------------|-------------|
| product_key       | INT             | Surrogate key uniquely identifying each product record in the product dimension table. |
| product_id        | INT             | A unique internal identifier assigned to the product. |
| product_number    | VARCHAR(50)     | Business product identifier used for tracking and referencing across systems. |
| product_name      | VARCHAR(50)     | Descriptive name of the product, including key characteristics. |
| category_id       | VARCHAR(50)     | Unique identifier for the product category, linking to its high-level classification. |
| category          | VARCHAR(50)     | Broad classification of the product (e.g., `Bikes`, `Components`). |
| subcategory       | VARCHAR(50)     | More detailed classification of the product within the category. |
| maintenance       | VARCHAR(50)     | Indicates whether the product requires maintenance (e.g., `Yes`, `No`). |
| cost              | INT             | The base cost of the product, measured in monetary units. |
| product_line      | NVARCHAR(50)    | The specific product line or series to which the product belongs (e.g., `Road`, `Mountain`). |
| start_date        | DATE            | The date when the product became available for sale or use. |

---

## 3. gold.fact_sales

**Purpose:**  
Stores transactional sales data at the line-item level. This fact table links to customer and product dimensions using surrogate keys and supports sales performance and trend analysis.

### Columns

| Column Name      | Data Type       | Description |
|------------------|-----------------|-------------|
| order_number     | VARCHAR(50)     | A unique alphanumeric identifier for each sales order (e.g., `SO54496`). |
| customer_key     | INT             | Surrogate key linking the sale to the customer dimension table. |
| product_key      | INT             | Surrogate key linking the sale to the product dimension table. |
| order_date       | DATE            | The date when the order was placed. |
| shipping_date    | DATE            | The date when the order was shipped to the customer. |
| due_date         | DATE            | The date when payment for the order was due. |
| price            | INT             | The price per unit of the product for the line item, in whole currency units. |
| quantity         | INT             | The number of units ordered for the product line item. |
| sales_amount     | INT             | The total monetary value of the sale for the line item, in whole currency units. |

---

## Notes

- All surrogate keys are generated in the **Gold Layer** to ensure consistent dimensional modeling.
- The Gold Layer is optimized for **BI tools, dashboards, and ad-hoc analytics**.
- Fact-to-dimension relationships are enforced using surrogate keys rather than business keys.

---


## Gold Layer Star Schema

![Gold Layer Star Schema](diagrams/GOLD_STAR_SCHEMA.drawio.svg)