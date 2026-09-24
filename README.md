# 🛒 Zepto E-Commerce Data Analysis & Inventory Intelligence (SQL)

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-003B57?style=for-the-badge&logo=SQL&logoColor=white)
![E-Commerce Analytics](https://img.shields.io/badge/Domain-Quick_Commerce_%26_Retail-orange?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

An end-to-end SQL data analysis portfolio project analyzing real-world scraped product inventory data from **Zepto**, one of India's leading quick-commerce platforms. This project covers database schema architecture, UTF-8 data pipeline ingestion, data cleaning, and 8+ strategic SQL queries extracting actionable business intelligence for pricing, revenue, stock management, and warehouse logistics.

---

## 📌 Executive Summary & Business Impact

Quick-commerce platforms operate on ultra-fast fulfillment cycles where product pricing, inventory availability, and warehouse distribution dictate profit margins. Analyzing **3,732 Stock Keeping Units (SKUs)** across diverse categories reveals:
- **Revenue Hotspots:** Identifying category-level revenue contributions via total available inventory valuation (`discounted_selling_price * available_quantity`).
- **Revenue Leakage Mitigation:** Spotting high-priced items (MRP > ₹300) currently marked out of stock to minimize missed sales opportunities.
- **Logistics & Fulfillment Optimization:** Segmenting inventory into weight classes (Low, Medium, Bulk) to streamline delivery planning and warehouse mass contribution.
- **Pricing & Promotional Dynamics:** Evaluating discount percentage distributions across product categories (e.g., Fresh Produce vs. Packaged Goods).

---

## 📊 Dataset Architecture & Schema

The dataset contains **3,732 SKU records** across **1,681 distinct product names** (representing variations in weight, pack size, and category listing).

### **Database Schema (`zepto` Table)**

| Column Name | Data Type | Constraint / Description |
| :--- | :--- | :--- |
| `sku_id` | `SERIAL` | Primary Key (Auto-incrementing SKU Identifier) |
| `category` | `VARCHAR(100)` | Product category classification |
| `name` | `VARCHAR(255)` | `NOT NULL` Product commercial name |
| `mrp` | `NUMERIC(10,2)` | Maximum Retail Price (converted to ₹ Rupees) |
| `discount_percent` | `NUMERIC(5,2)` | Promotional discount percentage offered |
| `discounted_selling_price` | `NUMERIC(10,2)` | Final customer selling price (converted to ₹ Rupees) |
| `available_quantity` | `INTEGER` | Current units available in inventory |
| `weight_in_grams` | `INTEGER` | Unit weight or volume in grams |
| `out_of_stock` | `BOOLEAN` | Stockout status flag (`TRUE` = Out of Stock, `FALSE` = In Stock) |
| `quantity` | `INTEGER` | Pack quantity size |

---

## 🛠️ Pipeline & Data Cleaning Operations

Before running analytics queries, the raw scraped data underwent several production cleaning transformations:

1. **UTF-8 Encoding Correction:** Resolved CSV ingestion errors in PostgreSQL/pgAdmin by normalizing file encoding to standard UTF-8.
2. **Currency Standardization (Paise to Rupees):** Identified raw price values ingested in paise (e.g., 2,500 instead of ₹25.00) and standardized via database update:
   ```sql
   UPDATE zepto 
   SET mrp = mrp / 100.0, 
       discounted_selling_price = discounted_selling_price / 100.0;
   ```
3. **Anomaly & Zero-Value Scrubbing:** Filtered out erroneous records containing impossible zero MRP values:
   ```sql
   DELETE FROM zepto WHERE mrp = 0;
   ```
4. **Data Integrity & Null Auditing:** Executed null check across all 9 schema columns to guarantee complete data cleanliness prior to analytical querying.

---

## 🧠 Business Intelligence & Strategic SQL Queries

### 1. Top Value & Heavy Discount Analysis
Identifies the top 10 products offering discounts of 50% or more on MRP to evaluate promotional aggressiveness.
```sql
SELECT DISTINCT name, mrp, discount_percent 
FROM zepto 
ORDER BY discount_percent DESC 
LIMIT 10;
```

---

### 2. High-Value Stockout Risk Analysis
Highlights premium items (MRP > ₹300) currently out of stock to alert supply chain teams of urgent restock requirements.
```sql
SELECT DISTINCT name, mrp 
FROM zepto 
WHERE out_of_stock = TRUE AND mrp > 300 
ORDER BY mrp DESC;
```

---

### 3. Estimated Inventory Revenue Contribution by Category
Calculates total gross revenue potential per category based on current stock levels and discounted selling price.
```sql
SELECT 
    category, 
    SUM(discounted_selling_price * available_quantity) AS total_revenue 
FROM zepto 
GROUP BY category 
ORDER BY total_revenue DESC;
```

---

### 4. High-Price, Low-Discount Product Identification
Pinpoints fast-selling popular products (MRP > ₹500, discount < 10%) that sustain high retail demand without requiring promotional price cuts.
```sql
SELECT DISTINCT name, mrp, discount_percent 
FROM zepto 
WHERE mrp > 500 AND discount_percent < 10 
ORDER BY mrp DESC, discount_percent DESC;
```

---

### 5. Category-Level Average Discount Benchmarking
Ranks categories by average discount percentage to discover where price reductions are concentrated.
```sql
SELECT 
    category, 
    ROUND(AVG(discount_percent), 2) AS avg_discount 
FROM zepto 
GROUP BY category 
ORDER BY avg_discount DESC 
LIMIT 5;
```

---

### 6. Unit Economics: Price per Gram Metrics
Evaluates value-for-money metrics across products weighing 100g or more.
```sql
SELECT DISTINCT 
    name, 
    weight_in_grams, 
    discounted_selling_price, 
    ROUND(discounted_selling_price / weight_in_grams, 4) AS price_per_gram 
FROM zepto 
WHERE weight_in_grams >= 100 
ORDER BY price_per_gram ASC;
```

---

### 7. Warehouse Weight Segmentation (Logistics Tiering)
Uses conditional logic to classify items into weight tiers for delivery vehicle load planning.
```sql
SELECT DISTINCT 
    name, 
    weight_in_grams,
    CASE 
        WHEN weight_in_grams < 1000 THEN 'Low'
        WHEN weight_in_grams < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM zepto;
```

---

### 8. Total Category Inventory Mass Analysis
Calculates cumulative warehouse mass contribution by multiplying product unit weight by available stock quantity.
```sql
SELECT 
    category, 
    SUM(weight_in_grams * available_quantity) AS total_weight 
FROM zepto 
GROUP BY category 
ORDER BY total_weight DESC;
```

---

## 🚀 How to Reproduce Locally

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/your-username/zepto-ecommerce-sql-analysis.git
   cd zepto-ecommerce-sql-analysis
   ```

2. **Setup PostgreSQL Database:**
   - Open pgAdmin 4 or PostgreSQL CLI.
   - Create a new database: `CREATE DATABASE zepto_db;`
   - Execute the DDL schema in `schema.sql`.

3. **Import Dataset:**
   - Convert `zepto.csv` to UTF-8 encoding if needed.
   - Import the dataset into the `zepto` table via pgAdmin GUI or `\copy` command (excluding `sku_id` auto-generated primary key).

4. **Run Analytics Queries:**
   - Execute queries provided in `queries.sql` to generate insights.

---

## 🛠️ Tech Stack & Skills Demonstrated

* **Database Engine:** PostgreSQL 15+ / pgAdmin 4
* **SQL Skills:** DDL, Data Cleaning & Encoding, Type Casting, Conditional Logic (`CASE WHEN`), Window Functions & Aggregations, Unit Economics Calculations.
* **Domain Expertise:** Quick-Commerce, Retail Inventory Management, SKU Architecture, Supply Chain Logistics.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
