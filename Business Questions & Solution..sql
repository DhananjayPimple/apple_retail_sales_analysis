-- Apple Sales Project (1 Million Rows)

SELECT * FROM category ;
SELECT * FROM products ;
SELECT * FROM stores ;
SELECT * FROM sales ;
SELECT * FROM warranty ;

-- EDA

SELECT DISTINCT(repair_status) FROM warranty ;
SELECT COUNT(*) FROM sales ;

-- Improving Query Performance

CREATE INDEX sales_product_id ON sales(product_id) ;
CREATE INDEX sales_store_id ON sales(store_id) ;
CREATE INDEX sales_sale_date ON sales(sale_date) ;

EXPLAIN ANALYZE
SELECT * 
FROM sales 
WHERE product_id = 'P-44' ;

EXPLAIN ANALYZE
SELECT *
FROM sales
WHERE store_id = 'ST-31' ;


-- Business Problems

-- Q 1) Find the number of stores in each country.

-- Ans

SELECT country, COUNT(store_id) AS number_of_stores
FROM stores 
GROUP BY country
ORDER BY number_of_stores DESC ;

-- Q 2) Calculate the total number of units sold by each store.

-- Ans

SELECT s1.store_id, s1.store_name, SUM(s2.quantity) AS Total_Units 
FROM stores AS s1
JOIN sales AS s2 ON s1.store_id = s2.store_id
GROUP BY s1.store_id, s1.store_name
ORDER BY Total_Units DESC ;


-- Q 3) Identify how many sales occurred in December 2023.

-- Ans

-- Approach 1

SELECT COUNT(sale_id)
FROM sales
WHERE sale_date BETWEEN '2023-12-01' AND '2023-12-31' ;


-- Approach 2

SELECT COUNT(sale_id) AS Total_Sales 
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023' ;


-- Q 4) Determine how many stores have never had a warranty claim filed.

-- Ans 

-- Approach 1 (Using Subquery)
EXPLAIN ANALYZE
SELECT COUNT(store_id) FROM stores
WHERE store_id NOT IN 
(
	SELECT DISTINCT(store_id)
	FROM warranty AS w
	LEFT JOIN sales AS s ON w.sale_id = s.sale_id 
) ;

-- Approach 2 (Using CTE)

WITH claims AS
(
SELECT DISTINCT(store_id)
FROM warranty AS w
LEFT JOIN sales AS s ON w.sale_id = s.sale_id
)

SELECT COUNT(store_id)
FROM stores 
WHERE store_id NOT IN (SELECT store_id FROM claims) ;


-- Q 5) Calculate the percentage of warrranty claims marked as 'Wrranty Void'

-- Ans.

SELECT ROUND((COUNT(claim_id) / (SELECT COUNT(*) FROM warranty) :: numeric) * 100, 2)
FROM warranty
WHERE repair_status = 'Warranty Void'


-- Q 6) Identify which store has highest total units in the last year.

-- Ans. 

SELECT s1.store_id, s2.store_name, SUM(s1.quantity)
FROM sales AS s1
JOIN stores AS s2 ON s1.store_id = s2.store_id
WHERE sale_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '1 YEAR'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1 ;


-- Q 7) Count the number of unique products sold in the last year.

-- Ans. 

SELECT COUNT(DISTINCT(product_id))
FROM sales 
WHERE sale_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '1 YEAR'


-- Q 8) Find the average price of products in each category.

-- Ans.

SELECT p.category_id, c.category_name, ROUND(AVG(p.price)) AS avg_price 
FROM products AS p
JOIN category AS c ON p.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 2 ASC ;


-- Q 9) How many warranty claims were filed 2020?

-- Ans. 

SELECT COUNT(*)
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2020 ;


-- Q 10) For each store, identify the best selling day based on highest quantity sold.

-- Ans.

SELECT *
FROM 
(
	SELECT store_id, TO_CHAR(sale_date, 'Day'), SUM(quantity),
	RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rank
	FROM sales
	GROUP BY store_id, sale_date
)AS sub
WHERE sub.rank = 1 ;


-- Q 11) Identify the least selling product from each country based on total units sold.

-- Ans. 

WITH product_rank AS 
(
	SELECT s2.country, p.product_name,
	RANK() OVER(PARTITION BY s2.country ORDER BY SUM(s1.quantity)) AS rank
	FROM products AS p
	JOIN sales AS s1 ON p.product_id = s1.product_id
	JOIN stores AS s2 ON s1.store_id = s2.store_id
	GROUP BY 1, 2
)

SELECT *
FROM product_rank
WHERE rank = 1 ;


-- Q 12) Calculate how many warranty claims were filed within 180 days of product sale.

-- Ans. 

SELECT COUNT(claim_date)
FROM sales AS s
JOIN warranty AS w ON s.sale_id = w.sale_id
WHERE claim_date - sale_date <= 180 ;


-- Q 13) Determine how many warranty claims filed for product launched in the last two years.

-- Ans.


SELECT p.product_name, COUNT(claim_id) AS no_of_claims, COUNT(s.sale_id)
FROM warranty AS w
RIGHT JOIN sales AS s ON s.sale_id = w.sale_id
JOIN products AS p ON s.product_id = p.product_id
WHERE p.launch_date >= (SELECT MAX(launch_date) FROM products) - INTERVAL '2 Year'
GROUP BY 1
HAVING COUNT(claim_id) > 0 ;


-- Q 14) List the months in the last three years where sales exceeded 5000 units in the USA.
					
-- Ans. 

SELECT 
	TO_CHAR(s1.sale_date, 'MM-YYYY') AS month,
	SUM(s1.quantity) AS total_units_sold
FROM  sales AS s1
JOIN  stores AS s2 ON s1.store_id = s2.store_id
WHERE 
	s2.country = 'USA' AND 
	s1.sale_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '3 YEAR' 
GROUP BY 1
HAVING SUM(s1.quantity) > 5000 ;


-- Q 15) Identify the product category with the most warranty claims filed in the last two years.

-- Ans.

SELECT c.category_id, c.category_name, COUNT(w.claim_id) AS claims_filed
FROM warranty AS w
RIGHT JOIN sales AS s1 ON w.sale_id = s1.sale_id
JOIN products AS p ON s1.product_id = p.product_id
JOIN category AS c ON c.category_id = p.category_id
WHERE w.claim_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '2 YEAR'
GROUP BY 1, 2 
ORDER BY claims_filed DESC ;


-- Q 16) Determine the percentage chance of receiving warranty claims after each purchase for each country.

-- Ans. 

SELECT 
	country, total_units_sold, total_claims,
	ROUND(COALESCE (total_claims::numeric / total_units_sold::numeric * 100, 0)) AS percentage_claims
FROM
(
	SELECT 
		s2.country, SUM(s1.quantity) AS total_units_sold, 
		COUNT(w.claim_id) AS total_claims
	FROM stores AS s2
	RIGHT JOIN sales AS s1 ON s1.store_id = s2.store_id
	left JOIN warranty AS w ON s1.sale_id = w.sale_id
	GROUP BY s2.country 
)AS sub
ORDER BY 3 DESC ;


-- Q 17) Analyze the year-by-year growth ratio for each store. 

-- Ans.

WITH yearly_sales AS 
(
	SELECT 
		s1.store_id, 
		s2.store_name, 
		EXTRACT(YEAR FROM sale_date) AS year, 
		SUM(s1.quantity*p.price) AS total_sales
	FROM sales AS s1
	JOIN products AS p ON s1.product_id = p.product_id
	JOIN stores AS s2 ON s2.store_id = s1.store_id
	GROUP BY 1, 2, 3
	ORDER BY 2,3
),

Growth_Ratio AS
(
SELECT 
	store_name, 
	year, 
	LAG(total_sales, 1) OVER(PARTITION BY store_name ORDER BY year) AS Last_Year_Sale,
	total_sales AS Current_Year_Sale
FROM yearly_sales
)

SELECT 
	store_name,
	year,
	last_year_sale,
	current_year_sale,
	ROUND((current_year_sale - last_year_sale)::numeric / last_year_sale::numeric * 100, 2) AS growth_ratio 
FROM growth_ratio 
WHERE 
	last_year_sale IS NOT NULL
	AND
	year <> EXTRACT(YEAR FROM CURRENT_DATE) ;

/*
Q 18) Calculate the correlation between product price and warranty claims for products sold 
in the last five years segmented by price range.
*/

-- Ans.

SELECT 
	CASE 
		WHEN p.price <  500 THEN 'Affordable Product'
		WHEN p.price <  1000 THEN 'Mid Range Product'
		WHEN p.price >= 1000 THEN 'Expensive Product'
	END AS price_segment,
	COUNT(claim_id) AS total_claims
FROM warranty AS w 
LEFT JOIN sales AS s ON s.sale_id = w.sale_id
JOIN products AS p ON s.product_id = p.product_id
WHERE w.claim_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '5 YEAR' 
GROUP BY 1
ORDER BY 2 DESC ;

/* 
	There is a negative correlation between price of product and no of claims 
	as the price of product increases the no. of claims decreases.
	
*/


/*
	Q 19) Identify the store with the highest percentage of "Paid Repaired" claims
	      relative to total claims filed.
*/

-- Ans. 

WITH All_Claims AS 
(
	SELECT 
		s1.store_id, 
		s2.store_name, 
		COUNT(w.claim_id) AS total_claims
	FROM warranty AS w
	LEFT JOIN sales AS s1 ON s1.sale_id = w.sale_id
	JOIN stores AS s2 ON s2.store_id = s1.store_id
	GROUP BY 1, 2
),

Paid_Repaired_Claims AS
(
		SELECT 
		s1.store_id, 
		s2.store_name, 
		COUNT(w.claim_id) AS paid_repaired
	FROM warranty AS w
	LEFT JOIN sales AS s1 ON s1.sale_id = w.sale_id
	JOIN stores AS s2 ON s2.store_id = s1.store_id
	WHERE w.repair_status = 'Paid Repaired'
	GROUP BY 1, 2
	
)

SELECT 
	ac.store_id, ac.store_name, 
	prc.paid_repaired, 
	ac.total_claims,
	ROUND( (prc.paid_repaired::numeric / ac.total_claims::numeric) * 100, 2 ) AS percentage_paid_repaired
FROM All_Claims AS ac
JOIN Paid_Repaired_Claims AS prc ON ac.store_id = prc.store_id ;


/*
	Q 20) Write a query to calculate the monthly running totals of sales for each store over the 
	      past four years and compare trends during this period.
*/

-- Ans.

WITH monthly_sales AS
(
	SELECT 
		s1.store_id, 
		s2.store_name,
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
		SUM(p.price*s1.quantity) AS total_revenue
	FROM sales AS s1
	JOIN products AS p ON p.product_id = s1.product_id
	JOIN stores AS s2 ON s2.store_id = s1.store_id 
	WHERE sale_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '4 YEAR' 
	GROUP BY 1,2,3,4
	ORDER BY 1,2,3,4
)

SELECT 
	store_id,
	store_name,
	year,
	month,
	total_revenue,
	SUM(total_revenue) OVER(PARTITION BY store_id ORDER BY year, month) AS running_total
FROM monthly_sales ;


/*
	Q 21) Analyze product sales ternds over time, segmented into key periods: from launch 
		  to 6 months, 6-12 months, 12-18 months, and beyond 18 months.
*/

-- Ans.

SELECT 
	p.product_name,
	CASE 
		WHEN s.sale_date BETWEEN p.launch_date AND  p.launch_date + INTERVAL '6 MONTH' THEN '0-6 Month'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 MONTH' AND p.launch_date + INTERVAL '12 MONTH' THEN '6-12 Month'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 MONTH' AND  p.launch_date + INTERVAL '18 MONTH' THEN '12-18 Month'
		ELSE '18+ Month'
	END AS plc,
	SUM(s.quantity) AS total_quantity
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC ;








