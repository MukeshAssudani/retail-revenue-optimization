
-- 1. Count the total number of products, along with the number of non-missing values in description,  listing_price, and last_visited.
SELECT COUNT(*) as total_rows, COUNT(NULLIF(info.description,'')) as count_description, COUNT(NULLIF(finance.listing_price,'')) as count_listing_price, COUNT(NULLIF(traffic.last_visited,'')) as count_last_visited
FROM retail_revenue_optimization.info
INNER JOIN retail_revenue_optimization.traffic
ON traffic.product_id = info.product_id
INNER JOIN retail_revenue_optimization.finance
ON finance.product_id = info.product_id;

-- 2) Find out how listing_price varies between Adidas and Nike products.
SELECT brands.brand, CAST(listing_price AS INTEGER) as list_price, COUNT(finance.product_id)
FROM retail_revenue_optimization.brands
INNER JOIN retail_revenue_optimization.finance
ON brands.product_id=finance.product_id
WHERE finance.listing_price>0
GROUP BY brand, list_price
ORDER BY brand;

-- 3.Create labels for products grouped by price range and brand.
SELECT CASE 
WHEN brands.brand=' ' THEN 'Unknown'
ELSE brands.brand
END
FROM retail_revenue_optimization.brands;

UPDATE retail_revenue_optimization.brands
SET brand = CASE 
                WHEN brand = '' THEN 'Unknown'
                ELSE brand
            END;
SELECT brand, COUNT(brand) FROM retail_revenue_optimization.brands GROUP BY brand;

SELECT brands.brand, SUM(revenue) AS total_revenue,COUNT(finance.listing_price) AS count,CASE
WHEN finance.listing_price<50 THEN '0-50'
WHEN finance.listing_price>=50 AND finance.listing_price<=200 THEN '50-200'
ELSE '>200' END AS price_category
FROM retail_revenue_optimization.brands
INNER JOIN retail_revenue_optimization.finance
ON brands.product_id=finance.product_id
GROUP BY brands.brand, price_category
ORDER BY count ASC;

-- 4) Calculate the average discount offered by brand.
SELECT  brands.brand, AVG(discount) * 100 AS avg_discount
FROM retail_revenue_optimization.brands
INNER JOIN retail_revenue_optimization.finance
ON brands.product_id=finance.product_id
GROUP BY brands.brand;


-- 5. Ratings and reviews by product description length

 SELECT ROUND(LENGTH(info.description)/100)*100 AS desc_length, ROUND(AVG(CAST(rating AS DECIMAL)),2) AS average_rating
 FROM retail_revenue_optimization.info
 INNER JOIN retail_revenue_optimization.reviews
 ON info.product_id=reviews.product_id
 GROUP BY desc_length
 ORDER BY desc_length ASC;

-- 6.Count the number of reviews per brand per month.

SELECT brands.brand, EXTRACT(month FROM traffic.last_visited) AS mnth, COUNT(reviews.reviews) AS review
FROM retail_revenue_optimization.brands
INNER JOIN retail_revenue_optimization.traffic
ON brands.product_id=traffic.product_id
INNER JOIN retail_revenue_optimization.reviews
ON brands.product_id=reviews.product_id
GROUP BY brands.brand, mnth
ORDER BY brands.brand, mnth;

-- 7. Top 10 Revenue Generated Products with Brands
SELECT info.product_name, brands.brand,SUM(finance.revenue) AS total_revenue
FROM retail_revenue_optimization.info 
INNER JOIN retail_revenue_optimization.brands
ON info.product_id=brands.product_id
INNER JOIN retail_revenue_optimization.finance
ON info.product_id=finance.product_id
WHERE info.product_name IS NOT NULL 
AND  finance.revenue IS NOT NULL
AND brands.brand IS NOT NULL
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 8)  Top 5 Expensive footwear
SELECT brands.brand, CAST(finance.listing_price AS Integer) AS expensive_shoes
FROM retail_revenue_optimization.finance
INNER JOIN retail_revenue_optimization.brands
ON brands.product_id=finance.product_id
ORDER BY expensive_shoes DESC
LIMIT 5;


-- 9.  Footwear product performance
WITH footwear AS
( SELECT CAST(info.description AS CHAR(225)) AS descr, CAST(finance.revenue AS Integer) AS rev
FROM retail_revenue_optimization.info
INNER JOIN retail_revenue_optimization.finance 
ON info.product_id=finance.product_id
WHERE info.description LIKE '%shoe%'
OR info.description LIKE '%foot%'
OR info.description LIKE '%trainer%')

SELECT COUNT(*) AS num_of_footwear, AVG(rev) AS Avg_revenue
FROM footwear;

-- 10. Clothing product performance
WITH footwear AS
( SELECT CAST(info.description AS CHAR(225)) AS descr, CAST(finance.revenue AS Integer) AS rev
FROM retail_revenue_optimization.info
INNER JOIN retail_revenue_optimization.finance 
ON info.product_id=finance.product_id
WHERE info.description NOT LIKE '%shoe%'
AND info.description NOT LIKE '%foot%'
AND info.description NOT LIKE '%trainer%')

SELECT COUNT(NULLIF(descr,'')) AS num_clothing_brand, AVG(rev) AS avg_revenue FROM footwear;


