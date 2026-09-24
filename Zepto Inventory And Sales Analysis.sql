drop table if exists zepto;

create table zepto(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(8,2),
discountPercent NUMERIC(5,2),
availableQuantity INTEGER,
discountedSellingPrice NUMERIC(8,2),
weightInGms INTEGER,
outOfStock BOOLEAN,
quantity INTEGER
);

--Data Exploration

--Count of rows
SELECT COUNT(*) FROM zepto;

--Sample data
SELECT * FROM zepto
LIMIT 10;

--Finding Null Values
SELECT * FROM zepto
WHERE name is NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--Different Product Categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--PRODUCT IN STOCK/OUT OF STOCK
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

--PRODUCT NAMES PRESENT MULRIPLE TIMES
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) >1 
ORDER BY COUNT(sku_id) DESC;


--DATA CLEANING

-- prod with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--CONVERT PAISE TO RS
UPDATE zepto 
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

--SOLVING BUSINESS PROBLEMS
--Q1.Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name,mrp,discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

--Q2. WHAT ARE THE PRODUCTS WITH HIGH MRP BUT OUT OF STOCK
SELECT DISTINCT name,mrp
FROM zepto 
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

--Q3. CALCULATE ESTIMATED REVENUE FOR EACH CATEGORY
SELECT category
SUM(discountedSellingPrice * availableQuantity AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

--Q4. FIND PRODUCTS WHERE MRP > $500 AND DISCOUNT IS < 10%
SELECT DISTINCT name,mrp,discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. IDENTIFY TOP 5 CATEGORIES OFFERING HIGHEST AVG DISCOUNT PERCENT
SELECT category, 
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

--Q6. FIND PRICE PER GRAM FOR PROD ABOVE 100G AND SORT BY BEST VALUE
SELECT DISTINCT name,weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram

--Q7. GROUP THE PRODUCTS INTO CATEGORIES LIKE LOW,MEDIUM,BULK (when to add 'comma' when not to)
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

-- Q8. WHAT IS THE TOTAL INVENTORY WEIGHT PER CATEGORY
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;

