# 🛒 E-Commerce Sales Performance Analysis

## 📌 Project Overview

This project analyzes an e-commerce sales dataset containing messy transactional data to uncover business insights through **data cleaning, exploratory data analysis (EDA), and dashboard visualization**.

The project simulates a real-world analytics workflow, beginning with raw, inconsistent data and ending with actionable business insights through SQL and Power BI.

---

## 🎯 Business Problem

E-commerce businesses generate large amounts of transactional data, but inconsistent and messy data often makes analysis difficult.

The goal of this project is to:

- Clean and standardize messy sales data
- Identify sales trends and customer purchasing behavior
- Analyze product and regional performance
- Detect anomalies and high-value transactions
- Create an interactive dashboard for business monitoring

---

## 📂 Dataset Description

The dataset represents fictional but realistic **e-commerce transaction data** and includes intentionally messy values to simulate real-world business scenarios.

### Dataset Features

- Duplicate order IDs
- Missing values
- Inconsistent customer name formatting
- Incorrect product category spelling
- Mixed date formats
- Currency values stored as text
- Duplicate transactions

### Main Columns

| Column | Description |
|--------|-------------|
| order_id | Unique order identifier |
| order_date | Date of transaction |
| customer_name | Customer full name |
| city | Customer city |
| product_name | Purchased product |
| product_category | Product category |
| quantity | Number of products purchased |
| payment_method | Payment method |
| total_price | Total transaction amount |

---

## 🧹 Data Cleaning Process

Data cleaning was performed using **MySQL**. 

Data cleaning is the process of **identifying and correcting errors, inconsistencies, and inaccuracies** in a dataset to **enable reliable analysis**.

### Step 1: Removing duplicates

Detect duplicates using **Window Funtions** such as **ROW_NUMBER(), OVER(), PARTITION BY()**

Example:

```text
WITH check_duplicates AS
(
SELECT *, ROW_NUMBER() OVER(PARTITION BY
                                          order_id,
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
```

Then **Delete** rows that have value > 1 in row_num column, because it means that rows is a duplicate.

Example:

```text
DELETE
FROM sales_data_staging
WHERE row_num > 1;
```

### Step 2: Standardizing the data

Standardize the data, ensuring messy/inconsistent data follow a **single, consistent format, structure, and representation** so it can be **analyzed accurately** using **UPDATE** query **String Functions** such as **SUBSTRING(), TRIM(), REPLACE(), UPPER(), LOWER()**.

These are the types of data standardization that I do:

✅ Text standardization

Data were cleaned to improve formatting consistency by:

- Removing leading and trailing whitespace using `TRIM()`

Example:

```text
'   BIANCA YOUNG   ' → 'BIANCA YOUNG'
```

Query:

```text
UPDATE sales_data_staging3
SET customer_name = TRIM(customer_name);
```

- Converting inconsistent capitalization into a standardized name format

Example:

```text
'BIANCA YOUNG' → 'Bianca Young'
```

Query:

UPDATE sales_data_staging3
SET customer_name = CONCAT(LEFT(customer_name, 1), SUBSTRING(LOWER(customer_name), 2));

- Fixed inconsistent product category names

Example:

```text
'b00ks → books'
'fashi0n → fashion'
```

Query:

```text
UPDATE sales_data_staging3
SET product_category = REPLACE(product_category, '0', 'o');
```

- Standardized the currency format and converted it into USD

Example:

```text
Rp 3,570,560 → 27546.60
$20980.0 → 20980
USD 1386.25 → 1386.25
```

Query:

```text
UPDATE sales_data_staging3
SET total_price = SUBSTRING(total_price, 5)
WHERE total_price LIKE 'USD%';

UPDATE sales_data_staging3
SET total_price = REPLACE(total_price, ',', '');

UPDATE sales_data_staging3
SET total_price = CAST(SUBSTRING(total_price, 3) AS UNSIGNED) / 16000
WHERE total_price LIKE 'Rp%';
```

- Standardized the date format into YYYY-MM-DD format

Example:

```text
12-18-2024 → 2024-12-18
30/09/2024 → 2024-09-30
```

Query:

```text
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
```

✅ Data type standardization

Query:

```text
ALTER TABLE sales_data_staging3
MODIFY COLUMN order_date DATE;

ALTER TABLE sales_data_staging3
MODIFY COLUMN total_price DECIMAL(10,2);
```

### Step 3: Treating NULL and Blank Values

Query:

```text
UPDATE sales_data_staging3
SET city = 'Unknown'
WHERE city = '';

UPDATE sales_data_staging3
SET product_name = 'Missing Product'
WHERE product_name = '';

UPDATE sales_data_staging3
SET payment_method = 'Unknown'
WHERE payment_method = '';
```

### Step 4: Removing any columns or rows that are not relevant

Previously, we have made one or two columns to help us clean the data, like **row_num** and **new_order_id**. Because it's not relevant anymore, we can simply remove it from the table.

Query:

```text
ALTER TABLE sales_data_staging3
DROP COLUMN row_num,
DROP COLUMN row_num2,
DROP COLUMN new_order_id,
DROP COLUMN row_num3;
```

---

## 📊 Exploratory Data Analysis (EDA)

The EDA process was conducted using **SQL** to uncover business insights that can help management improve sales performance, customer engagement, and operational efficiency.

The analysis focused on answering key business questions and translating data findings into actionable recommendations.

---

### Analysis Performed

### Sales Performance
- Total revenue
- Revenue by product category
- Monthly revenue trends
- Revenue contribution percentage

### Customer Behavior
- Most popular payment methods
- Highest spending customers
- Average order value

### Geographic Analysis
- Revenue by city
- Best-performing category by city

### Product Analysis
- Top-selling products
- Product performance comparison

### Statistical Analysis
- Outlier detection for unusual transactions
- Monthly growth analysis using SQL window functions

---

## 📈 Dashboard

### Dashboard Title
**E-Commerce Sales Performance Dashboard**

The Power BI dashboard includes:

- KPI cards
- Revenue trends
- Category performance
- City-level sales analysis
- Payment behavior
- Product performance
- Interactive filtering

### Dashboard Preview

<img width="1303" height="731" alt="dashboard" src="https://github.com/user-attachments/assets/e9e87245-04c5-423e-9d82-e6076a7dd727" />

---

## 💡 Key Insights

## Executive Summary
- Overall Performance
- Total Revenue: 682.16K
- Total Orders: 500
- Average Order Value (AOV): 1.36K
- Total Quantity Sold: 2K

## Executive Insight
The business generated strong revenue performance from a relatively moderate number of transactions, indicating that transaction value per order is reasonably healthy.

## Executive Recommendation
Management should focus on increasing order frequency while maintaining average order value through bundling strategies and customer retention campaigns.

---

### Overall Performance

## 1. Revenue by Product Category

### Business Question
Which product category generates the highest revenue?

### Key Insight
**Sports** is the strongest-performing category **(~0.21M revenue)** and significantly outperforms all other categories. **Fashion** ranks second **(~0.14M)**, while **Books** contributes the least revenue.

### Business Recommendation
Management should prioritize inventory allocation, promotions, and marketing investment for Sport products since Sports is the highest revenue driver.
Management should also reassess low-performing categories by reviewing its pricing strategy, testing some kind of bundle offers to increase contribution, and evaluating its product assortment.

---

## 2. Revenue by City

### Business Question
Which cities contribute the most revenue?

### Key Insight
**Bali and Jakarta** are the highest revenue-contributing cities **(~0.14M each)**, followed by Medan. Meanwhile, **Bandung** contributes significantly less revenue.

### Business Recommendation
The company should strengthen operations and marketing efforts in top-performing cities, focusing on faster delivery, loyalty campaigns, and targeted ads in Bali and Jakarta.
The company should also investigate the underperforming cities by analyzing its customer demands, evaluating its logistics limitations, and launching localized promotions to increase its contributions.

---

## 3. Payment Method Preference Analysis

### Business Question
How do customers prefer to pay?

### Key Insight
**Cash On Delivery (COD)** is the most preferred payment method **(29.2%)**, followed closely by **Credit Card (25.8%)**.

### Business Recommendation
Management should optimize the checkout experience for COD and Credit Card. Since these drive most transactions, reducing payment friction and improving checkout UX can help.

---

## 4. Monthly Revenue Trend Analysis

### Business Question
How has sales performance changed over time?

### Key Insight
Monthly sales performance fluctuates significantly, with notable peaks reaching **67.46K** and several sharp declines near the end of the timeline. This suggests that there is inconsistent revenue momentum and a possibility of operational or demand instability.

### Business Recommendation
Management should investigate drivers of high-performing months and analyze the factors that contributed to revenue spikes like promotions, holidays, campaigns, and pricing.

---

## 5. Top Selling Products Analysis

### Business Question
Which products have the highest customer demand?

### Key Insight
Several products show significantly stronger purchase volume, with **Gaming** products leading demand **(97 units)**, followed by **Sunscreen** and **Cooking-related products**. This indicates customer demand is concentrated in specific product types, and product popularity does not always equal the highest revenue.

### Business Recommendation
Management should maintain inventory availability and promotional focus for top-selling products while evaluating low-performing products for optimization. Management can also cross-sell related items, for example: gaming accessories, sports bundles, and skincare bundles.

---


## 6. Monthly Sales Growth Analysis

### Business Question
How fast is the business growing month-over-month?

### Key Insight
Monthly sales growth demonstrates **high volatility**, with periods of strong revenue acceleration followed by sharp declines. Several months experienced substantial spikes in sales performance, while later periods show a significant slowdown, suggesting inconsistent business momentum.

### Business Recommendation
Management should investigate the drivers behind high-performing months and analyze the factors that contributed to sales spikes and replicate successful initiatives. Improving revenue stability to reduce volatility by implementing customer retention programs, loyalty incentives, etc. Management should also strengthen forecasting and inventory planning since growth fluctuates considerably.

---

## 🛠 Tools Used

- **MySQL** → Data Cleaning & EDA
- **Power BI** → Dashboard Visualization
- **Excel / CSV** → Data Source
- **GitHub** → Project Documentation

---

## 📁 Project Structure

```text
first-data-cleaning-eda-project/
│── data_source/
│   ├── messy_ecommerce_sales_data.csv
│   ├── clean_ecommerce_sales_data.csv
│
│── sql/
│   ├── data_cleaning.sql
│   ├── exploratory_data-analysis.sql
│
│── dashboard/
│   ├── dashboard.pbix
│
│── images/
│   ├── dashboard.png
│
│── README.md
```

---

## 👤 Author

**Muhammad Afif Taimullah**

Aspiring Data Analyst passionate about:
- Data Analytics
- SQL
- Business Intelligence
- Dashboard Development

GitHub: https://github.com/MhdAfifT

LinkedIn: http://www.linkedin.com/in/muhammad-afif-taimullah-557496248


