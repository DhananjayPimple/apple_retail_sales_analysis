## Apple Store's Retail Sales Data Analysis Using SQL

![Apple](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/0x0.webp) 

## 📖 Project Overview

This project involves a comprehensive analysis of over 1 million rows of Apple Store's retail sales data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally.

## 🛢 Database Schema

The project uses five main tables:

1. **stores**: Contains information about Apple retail stores.
   - `store_id`: Unique identifier for each store.
   - `store_name`: Name of the store.
   - `city`: City where the store is located.
   - `country`: Country of the store.

2. **category**: Holds product category information.
   - `category_id`: Unique identifier for each product category.
   - `category_name`: Name of the category.

3. **products**: Details about Apple products.
   - `product_id`: Unique identifier for each product.
   - `product_name`: Name of the product.
   - `category_id`: References the category table.
   - `launch_date`: Date when the product was launched.
   - `price`: Price of the product.

4. **sales**: Stores sales transactions.
   - `sale_id`: Unique identifier for each sale.
   - `sale_date`: Date of the sale.
   - `store_id`: References the store table.
   - `product_id`: References the product table.
   - `quantity`: Number of units sold.

5. **warranty**: Contains information about warranty claims.
   - `claim_id`: Unique identifier for each warranty claim.
   - `claim_date`: Date the claim was made.
   - `sale_id`: References the sales table.
   - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).

   ## 📌 Entity Relationship Diagram (ERD)

   ![ERD](https://github.com/user-attachments/assets/3ad9ae27-0674-4316-9175-02a0cbac72a2)

## 🎯 Objectives

- Analyze the sales distribution of Apple products across various geographical locations (i.e. cities, countries).
- Find out sales of Apple products across different time frames (i.e. month, year, date).
- Study the after sales service (i.e. warranty related issues) of differnt Apple stores.
- Explore the performance of different Apple products interms of sales.
- Prob into the realationship (If Any) between the products and their after sales service.

## 💡 Business Problems & Their Solution.

### 1. Find the number of stores in each country.

```sql
SELECT country, COUNT(store_id) AS number_of_stores
FROM stores 
GROUP BY country
ORDER BY number_of_stores DESC ;
```
![Ans1](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q1.png?raw=true)

### 2. Calculate the total number of units sold by each store.

```sql
SELECT s1.store_id, s1.store_name, SUM(s2.quantity) AS Total_Units 
FROM stores AS s1
JOIN sales AS s2 ON s1.store_id = s2.store_id
GROUP BY s1.store_id, s1.store_name
ORDER BY Total_Units DESC ;
```
![Ans2](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q2.png?raw=true)

### 3. Identify how many sales occurred in December 2023.

```sql
-- Approach 1

SELECT COUNT(sale_id) AS Total_Sales
FROM sales
WHERE sale_date BETWEEN '2023-12-01' AND '2023-12-31' ;


-- Approach 2

SELECT COUNT(sale_id) AS Total_Sales 
FROM sales
WHERE TO_CHAR(sale_date, 'MM-YYYY') = '12-2023' ;
```
![Ans3](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q3.png?raw=true)

### 4. Determine how many stores have never had a warranty claim filed.

```sql
-- Approach 1 (Using Subquery)

SELECT COUNT(store_id) AS no_of_stores FROM stores
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

SELECT COUNT(store_id) AS no_of_stores
FROM stores 
WHERE store_id NOT IN (SELECT store_id FROM claims) ;
```
![Ans4](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q4.png?raw=true)

### 5. Calculate the percentage of warranty claims marked as "Warranty Void".

```sql
SELECT ROUND((COUNT(claim_id) / (SELECT COUNT(*) FROM warranty) :: numeric) * 100, 2) AS percentage_wrranty_claim
FROM warranty
WHERE repair_status = 'Warranty Void' ;
```
![Ans5](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q5.png?raw=true)

### 6. Identify which store had the highest total units sold in the last year.

```sql
SELECT s1.store_id, s2.store_name, SUM(s1.quantity) AS total_units_sold
FROM sales AS s1
JOIN stores AS s2 ON s1.store_id = s2.store_id
WHERE sale_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '1 YEAR'
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 1 ;
```
![Ans6](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q6.png?raw=true)

### 7. Count the number of unique products sold in the last year.

```sql
SELECT COUNT(DISTINCT(product_id)) AS no_of_unique_products_sold
FROM sales 
WHERE sale_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '1 YEAR' ;
```
![Ans7](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q7.png?raw=true)

### 8. Find the average price of products in each category.

```sql
SELECT p.category_id, c.category_name, ROUND(AVG(p.price)) AS avg_price 
FROM products AS p
JOIN category AS c ON p.category_id = c.category_id
GROUP BY 1, 2
ORDER BY 2 ASC ;
```
![Ans8](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q8.png?raw=true)

### 9. How many warranty claims were filed in 2020?

```sql
SELECT COUNT(*) AS total_claims
FROM warranty
WHERE EXTRACT(YEAR FROM claim_date) = 2020 ;
```
![Ans9](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q9.png?raw=true)

### 10. For each store, identify the best-selling day based on highest quantity sold.

```sql
SELECT *
FROM 
(
	SELECT store_id, TO_CHAR(sale_date, 'Day') AS day, SUM(quantity) AS total_quantity ,
	RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS rank
	FROM sales
	GROUP BY store_id, sale_date
)AS sub
WHERE sub.rank = 1 ;
```
![Ans10](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q10.png?raw=true)

### 11. Identify the least selling product in each country for each year based on total units sold.

```sql
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
```
![Ans11](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q11.png?raw=true)

### 12. Calculate how many warranty claims were filed within 180 days of a product sale.

```sql
SELECT COUNT(claim_date) AS total_warranty_claims
FROM sales AS s
JOIN warranty AS w ON s.sale_id = w.sale_id
WHERE claim_date - sale_date <= 180 ;
```
![Ans12](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q12.png?raw=true)

### 13. Determine how many warranty claims were filed for products launched in the last two years.

```sql
SELECT p.product_name, COUNT(claim_id) AS no_of_claims, COUNT(s.sale_id) AS total_qty_sold
FROM warranty AS w
RIGHT JOIN sales AS s ON s.sale_id = w.sale_id
JOIN products AS p ON s.product_id = p.product_id
WHERE p.launch_date >= (SELECT MAX(launch_date) FROM products) - INTERVAL '2 Year'
GROUP BY 1
HAVING COUNT(claim_id) > 0 ;
```
![Ans13](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q13.png?raw=true)

### 14. List the months in the last three years where sales exceeded 5,000 units in the USA.

```sql
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
```
![Ans14](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q14.png?raw=true)

### 15. Identify the product category with the most warranty claims filed in the last two years.

```sql
SELECT c.category_id, c.category_name, COUNT(w.claim_id) AS claims_filed
FROM warranty AS w
RIGHT JOIN sales AS s1 ON w.sale_id = s1.sale_id
JOIN products AS p ON s1.product_id = p.product_id
JOIN category AS c ON c.category_id = p.category_id
WHERE w.claim_date >= (SELECT MAX(sale_date) FROM sales) - INTERVAL '2 YEAR'
GROUP BY 1, 2 
ORDER BY claims_filed DESC ;
```
![Ans15](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q15.png?raw=true)

### 16. Determine the percentage chance of receiving warranty claims after each purchase for each country.

```sql
SELECT 
	country, total_units_sold, total_claims,
	ROUND(COALESCE (total_claims::numeric / total_units_sold::numeric * 100, 0)) AS percent_claims_chance
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
```
![Ans16](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q16.png?raw=true)

### 17. Analyze the year-by-year growth ratio for each store.

```sql
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
```
![Ans17](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q17.png?raw=true)

### 18. Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range.

```sql
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
```
![Ans18](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q18.png?raw=true)

### 19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed.

```sql
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
```
![Ans19](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q19.png?raw=true)

### 20. Write a query to calculate the monthly running total of sales for each store over the past four years and compare trends during this period.

```sql
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
```
![Ans20](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q20.png?raw=true)

### 21. Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months.

```sql
SELECT 
	p.product_name,
	CASE 
		WHEN s.sale_date BETWEEN p.launch_date AND  p.launch_date + INTERVAL '6 MONTH' THEN '0-6 Month'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '6 MONTH' AND p.launch_date + INTERVAL '12 MONTH' THEN '6-12 Month'
		WHEN s.sale_date BETWEEN p.launch_date + INTERVAL '12 MONTH' AND  p.launch_date + INTERVAL '18 MONTH' THEN '12-18 Month'
		ELSE '18+ Month'
	END AS time_frame,
	SUM(s.quantity) AS total_quantity
FROM sales AS s
JOIN products AS p ON s.product_id = p.product_id
GROUP BY 1, 2
ORDER BY 1, 3 DESC ;
```
![Ans21](https://github.com/DhananjayPimple/apple_retail_sales_analysis/blob/main/Query%20Result%20Snapshots/Q21.png?raw=true)


## 🔬 Project Focus

This project primarily focuses on developing and showcasing the following SQL skills:

- **Complex Joins and Aggregations**: Demonstrating the ability to perform complex SQL joins and aggregate data meaningfully.
- **Window Functions**: Using advanced window functions for running totals, growth analysis, and time-based queries.
- **Data Segmentation**: Analyzing data across different time frames to gain insights into product performance.
- **Correlation Analysis**: Applying SQL functions to determine relationships between variables, such as product price and warranty claims.
- **Real-World Problem Solving**: Answering business-related questions that reflect real-world scenarios faced by data analysts.

## ✅ Conclusion

- UK being a country having highest no of Apple stores and Apple South Coast Plaza (USA) is a store having highest no of products sales.
- 58 out of 73 stores have never had a warranty claim filed.
- Laptop, Desktop & Smartphone in order have the highest avg price among all the products category available.
- Smartphone, Tablet & Wearable in order have the highest warranty claims filed among all the products category available.
- UAE, Spain & Itly in order have the highest percentage chance of receiving warranty claims among all the other countries.
- There is a negative correlation between price of product and no of warranty claims received as the price of product increases the no. of claims decreases. (i.e. Affordable products receive most wrranty claims while Expensive products receive least.)

## 📂 Dataset

- **Size**: 1 million+ rows of sales data (sales table).
- **Period Covered**: The data spans multiple years, allowing for long-term trend analysis.
- **Geographical Coverage**: Sales data from Apple stores across various countries.
- **Data Source**: https://www.kaggle.com/datasets
	
---
