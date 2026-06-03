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

## 1. Revenue by Product Category

### Business Question
Which product category generates the highest revenue?

### Key Insight
The analysis revealed that certain product categories contribute significantly more revenue than others, indicating stronger customer demand and higher transaction values.

### Business Recommendation
Management should prioritize inventory allocation, promotions, and marketing investment toward high-performing categories while reassessing strategies for underperforming segments.

---

## 2. Revenue by City

### Business Question
Which cities contribute the most revenue?

### Key Insight
Sales performance is concentrated in several high-performing cities, indicating regional differences in purchasing power and customer demand.

### Business Recommendation
The company should strengthen operations and marketing efforts in top-performing cities while exploring growth opportunities in lower-performing markets through localized campaigns and service improvements.

---

## 3. Payment Method Preference Analysis

### Business Question
How do customers prefer to pay?

### Key Insight
Customer payment behavior reveals clear preferences for certain payment methods, reflecting convenience and trust factors in purchasing decisions.

### Business Recommendation
Management should optimize checkout experience for preferred payment methods and consider incentives to increase adoption of cost-efficient payment channels.

---

## 4. Monthly Revenue Trend Analysis

### Business Question
How has sales performance changed over time?

### Key Insight
Revenue trends help identify periods of growth, stagnation, or decline, providing visibility into business performance and seasonal patterns.

### Business Recommendation
Management should identify successful factors behind high-performing periods and replicate those strategies while investigating causes behind declining performance.

---

## 5. Monthly Order Volume Trend

### Business Question
How does customer purchasing volume change over time?

### Key Insight
Order volume trends provide insight into customer demand fluctuations and operational workload requirements.

### Business Recommendation
The company should align inventory planning and operational capacity with seasonal demand trends to minimize stock shortages and operational bottlenecks.

---

## 6. Top Selling Products Analysis

### Business Question
Which products have the highest customer demand?

### Key Insight
A small number of products contribute disproportionately to total sales volume, indicating strong product-market fit and customer preference.

### Business Recommendation
Management should maintain inventory availability and promotional focus for top-selling products while evaluating low-performing products for optimization.

---

## 7. High-Value Customer Analysis

### Business Question
Who are the highest spending customers?

### Key Insight
The analysis identified a segment of high-value customers contributing substantial revenue, suggesting opportunities for customer retention and loyalty programs.

### Business Recommendation
The business should implement personalized offers, loyalty rewards, or targeted engagement strategies to maximize customer lifetime value.

---

## 8. Product Category Performance by City

### Business Question
What product categories perform best in each city?

### Key Insight
Customer preferences differ across geographic regions, with different product categories dominating sales in specific cities.

### Business Recommendation
Management should implement region-specific marketing strategies and optimize inventory distribution based on local customer demand.

---

## 9. Revenue Contribution Analysis

### Business Question
How much does each city contribute to overall sales?

### Key Insight
The business relies heavily on several key markets, creating potential revenue concentration risk.

### Business Recommendation
Management should diversify revenue growth efforts by strengthening lower-performing markets while maintaining strong performance in core revenue regions.

---

## 10. Outlier Transaction Detection

### Business Question
Are there unusual transactions that require investigation?

### Key Insight
Several transactions were significantly larger than typical purchase behavior, potentially representing bulk purchases, premium customers, or anomalies.

### Business Recommendation
Management should investigate high-value transactions to identify potential VIP customer segments, validate transaction legitimacy, and improve fraud monitoring.

---

## 11. Monthly Sales Growth Analysis

### Business Question
How fast is the business growing month-over-month?

### Key Insight
Monthly growth analysis reveals changes in business momentum and highlights periods of accelerated growth or performance decline.

### Business Recommendation
Management should identify successful strategies during growth periods and investigate causes of slowdown to improve long-term business performance.

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


