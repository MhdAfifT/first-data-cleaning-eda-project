--  SHOULD ANSWER --> What insights can help management improve sales and operations?

SELECT *
FROM sales_data_staging3;

-- Which product category generates the highest revenue?

SELECT
	product_category,
    SUM(total_price) AS total_revenue
FROM sales_data_staging3
GROUP BY product_category
ORDER BY total_revenue DESC;

-- Which cities contribute the most sales?

SELECT
	city, 
    SUM(total_price) AS total_sales
FROM sales_data_staging3
GROUP BY city
ORDER BY total_sales DESC;

-- Are there unusual transactions or fraud-like outliers?

SELECT *
FROM sales_data_staging3
WHERE total_price > (
				SELECT AVG(total_price) + 3 * STDDEV(total_price)
				FROM sales_data_staging3);

-- What payment methods are most popular?

SELECT
	payment_method,
    COUNT(payment_method) AS count
FROM sales_data_staging3
GROUP BY payment_method
ORDER BY count DESC;

-- How do sales trends change over time?

WITH cumulative_sales AS
(
SELECT
	SUBSTRING(order_date, 1, 7) AS `year_month`,
    SUM(total_price) AS total_sales
FROM sales_data_staging3
GROUP BY `year_month`
ORDER BY `year_month`
)

SELECT
	`year_month`,
    total_sales,
    SUM(total_sales) OVER(ORDER BY `year_month`) AS total_cumulative
FROM cumulative_sales;

-- How do order value change over time?

WITH cumulative_order AS
(
SELECT
	SUBSTRING(order_date, 1, 7) AS `year_month`,
    SUM(quantity) AS total_order
FROM sales_data_staging3
GROUP BY `year_month`
ORDER BY `year_month`
)

SELECT
	`year_month`,
    total_order,
    SUM(total_order) OVER(ORDER BY `year_month`) AS total_cumulative
FROM cumulative_order;

-- Which products have the highest demand?

SELECT
	product_name,
    SUM(quantity) AS quantity_sales
FROM sales_data_staging3
GROUP BY product_name
ORDER BY quantity_sales DESC;

-- Which customer have the highest spending? Top 5

SELECT
	customer_name,
    SUM(total_price) AS total_spend
FROM sales_data_staging3
GROUP BY customer_name
ORDER BY total_spend DESC
LIMIT 5;

-- What is the best category from each city?

WITH cities_top_category AS
(
SELECT
	city,
    product_category,
    SUM(total_price) AS total_spend
FROM sales_data_staging3
GROUP BY city, product_category
ORDER BY city, total_spend DESC
),
`rank` AS
(SELECT
	*,
    DENSE_RANK() OVER(PARTITION BY city ORDER BY total_spend DESC) AS ranking
FROM cities_top_category
)

SELECT
	*
FROM `rank`
WHERE ranking = 1;

-- What is each city contribution percentage for the sales?

WITH city_total_sales AS
(
SELECT 
	city,
	SUM(total_price) AS total_sales
FROM sales_data_staging3
GROUP BY city
ORDER BY total_sales DESC
),
grand_total_sales AS
(
SELECT 
	SUM(total_price) AS grand_total
FROM sales_data_staging3
)

SELECT
	city,
    ROUND(total_sales * 100 / (SELECT * FROM grand_total_sales), 2) AS contribution_percentage
FROM city_total_sales
GROUP BY city
ORDER BY contribution_percentage DESC;

-- What is the monthly growth of the sales?

WITH monthly_sales AS
(
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    SUM(total_price) AS revenue
FROM sales_data_staging3
GROUP BY month
)

SELECT
    month,
    revenue,
    LAG(revenue) OVER(ORDER BY month) AS previous_month,
    ROUND(
        (revenue - LAG(revenue) OVER(ORDER BY month))
        /
        LAG(revenue) OVER(ORDER BY month)
        * 100,
        2
    ) AS growth_percentage
FROM monthly_sales;