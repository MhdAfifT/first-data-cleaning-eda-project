-- DATA SET OVERVIEW

-- This dataset simulates raw transaction data from a growing Indonesian e-commerce company that sells products across multiple categories such as 
-- Electronics, Fashion, Beauty, Sports, Books, and Groceries.

-- The company collects daily sales transactions from customers across several Indonesian cities, but the data has never been properly standardized 
-- or validated. Because of this, the dataset contains many common real-world data quality issues that analysts often encounter in actual business environments.

-- Each row represents a single customer order transaction.

-- | Column             | Description                 |
-- | ------------------ | --------------------------- |
-- | `order_id`         | Unique order transaction ID |
-- | `customer_name`    | Customer full name          |
-- | `city`             | Customer city               |
-- | `product_category` | Product category            |
-- | `product_name`     | Purchased product           |
-- | `quantity`         | Number of items purchased   |
-- | `unit_price`       | Price per item              |
-- | `total_price`      | Total transaction value     |
-- | `payment_method`   | Payment type used           |
-- | `order_date`       | Date of transaction         |

-- This dataset includes realistic real-world problems such as:
-- 1. Missing values
-- 2. Duplicate rows
-- 3. Mixed date formats
-- 4. Inconsistent currencies
-- 5. Typos
-- 6. Wrong casing
-- 7. Extra spaces
-- 8. Outliers
-- 9. Inconsistent payment methods

-- \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--

-- 1. REMOVE DUPLICATES

WITH check_duplicates AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id,
										  customer_name,
										  city, 
										  product_category, 
										  product_name, 
									      quantity, 
										  unit_price, 
										  total_price, 
										  payment_method, 
									      order_date) AS row_num
FROM sales_data_raw
)

SELECT *
FROM check_duplicates
WHERE row_num > 1;

CREATE TABLE `sales_data_staging` (
  `order_id` text,
  `customer_name` text,
  `city` text,
  `product_category` text,
  `product_name` text,
  `quantity` int DEFAULT NULL,
  `unit_price` double DEFAULT NULL,
  `total_price` text,
  `payment_method` text,
  `order_date` text,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sales_data_staging
SELECT  *, 
		ROW_NUMBER() OVER(PARTITION BY order_id,
										  customer_name,
										  city, 
										  product_category, 
										  product_name, 
									      quantity, 
										  unit_price, 
										  total_price, 
										  payment_method, 
									      order_date) AS row_num
FROM sales_data_raw;

SELECT *
FROM sales_data_staging
WHERE row_num > 1;

DELETE
FROM sales_data_staging
WHERE row_num > 1;

WITH check_order_id_duplicates AS
(
SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY order_id) AS row_num2
FROM sales_data_staging
)

SELECT *
FROM check_order_id_duplicates
WHERE row_num2 > 1;

CREATE TABLE `sales_data_staging2` (
  `order_id` text,
  `customer_name` text,
  `city` text,
  `product_category` text,
  `product_name` text,
  `quantity` int DEFAULT NULL,
  `unit_price` double DEFAULT NULL,
  `total_price` text,
  `payment_method` text,
  `order_date` text,
  `row_num` int DEFAULT NULL,
  `row_num2` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sales_data_staging2
SELECT
	*,
    ROW_NUMBER() OVER(PARTITION BY order_id) AS row_num2
FROM sales_data_staging;

SELECT *
FROM sales_data_staging2
WHERE row_num2 > 1;

WITH new_order_id AS
(
SELECT
	*,
	CASE
		WHEN row_num2 = 1 THEN order_id
        ELSE CONCAT(order_id, '-', row_num2 - 1)
	END AS new_order_id
FROM sales_data_staging2
)

UPDATE sales_data_staging2 sds2
SET sds2.order_id = noi.new_order_id;

CREATE TABLE `sales_data_staging3` (
  `order_id` text,
  `customer_name` text,
  `city` text,
  `product_category` text,
  `product_name` text,
  `quantity` int DEFAULT NULL,
  `unit_price` double DEFAULT NULL,
  `total_price` text,
  `payment_method` text,
  `order_date` text,
  `row_num` int DEFAULT NULL,
  `row_num2` int DEFAULT NULL,
  `new_order_id` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sales_data_staging3
SELECT
	*,
	CASE
		WHEN row_num2 = 1 THEN order_id
        ELSE CONCAT(order_id, '-', row_num2 - 1)
	END AS new_order_id
FROM sales_data_staging2;

UPDATE sales_data_staging3
SET order_id = new_order_id;

SELECT *, ROW_NUMBER() OVER(PARTITION BY order_id) AS row_num3
FROM sales_data_staging3;

SELECT *
FROM sales_data_staging3;

-- 2. STANDARDIZE THE DATA

SELECT *
FROM sales_data_staging3;

UPDATE sales_data_staging3
SET customer_name = TRIM(customer_name);

UPDATE sales_data_staging3
SET customer_name = CONCAT(LEFT(customer_name, 1), SUBSTRING(LOWER(customer_name), 2));

UPDATE sales_data_staging3
SET product_category = REPLACE(product_category, '0', 'o');

UPDATE sales_data_staging3
SET payment_method = 'Credit Card'
WHERE payment_method = 'credit card';

UPDATE sales_data_staging3
SET payment_method = 'Cash On Delivery'
WHERE payment_method = 'COD';

UPDATE sales_data_staging3
SET order_date = REPLACE(order_date, '/', '-')
WHERE order_date LIKE '%/%';

SELECT
	order_date,
    SUBSTRING_INDEX(order_date, '-', 1) AS D1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(order_date, '-', 2), '-', -1) AS D2,
    SUBSTRING_INDEX(order_date, '-', -1) AS D3
FROM sales_data_staging3
ORDER BY 1;

UPDATE sales_data_staging3
SET order_date =
    CASE
        WHEN CAST(SUBSTRING_INDEX(order_date, '-', 1) AS UNSIGNED) > 12 THEN STR_TO_DATE(order_date, '%d-%m-%Y')
		ELSE STR_TO_DATE(order_date, '%m-%d-%Y')
    END
WHERE order_date REGEXP '2024$|2025$|2026$';

ALTER TABLE sales_data_staging3
MODIFY COLUMN order_date DATE;

UPDATE sales_data_staging3
SET total_price = SUBSTRING(total_price, 2)
WHERE total_price LIKE '$%';

UPDATE sales_data_staging3
SET total_price = SUBSTRING(total_price, 5)
WHERE total_price LIKE 'USD%';

UPDATE sales_data_staging3
SET total_price = REPLACE(total_price, ',', '');

UPDATE sales_data_staging3
SET total_price = CAST(SUBSTRING(total_price, 3) AS UNSIGNED) / 16000
WHERE total_price LIKE 'Rp%';

ALTER TABLE sales_data_staging3
MODIFY COLUMN total_price DECIMAL(10,2);

SELECT *
FROM sales_data_staging3;

-- 3. TREAT NULL AND BLANK VALUES

UPDATE sales_data_staging3
SET city = 'Unknown'
WHERE city = '';

UPDATE sales_data_staging3
SET product_name = 'Missing Product'
WHERE product_name = '';

UPDATE sales_data_staging3
SET payment_method = 'Unknown'
WHERE payment_method = '';

SELECT *
FROM sales_data_staging3;

-- 4. REMOVE ANY COLUMNS OR ROWS THAT DOESN'T RELEVANT

ALTER TABLE sales_data_staging3
DROP COLUMN row_num,
DROP COLUMN row_num2,
DROP COLUMN new_order_id,
DROP COLUMN row_num3;