
/* 1. Get all records */
SELECT *
FROM kinesis_firehose_destination_g1;


/* 2. Calculate total revenue per row */
SELECT 
    orderid,
    product_name,
    quantity,
    price,
    quantity * price AS total_amount
FROM kinesis_firehose_destination_g1;


/* 3. Total revenue of all orders */
SELECT 
    SUM(quantity * price) AS total_revenue
FROM kinesis_firehose_destination_g1;


/* 4. Total quantity sold per product */
SELECT 
    product_name,
    SUM(quantity) AS total_quantity
FROM kinesis_firehose_destination_g1
GROUP BY product_name;


/* 5. Total revenue per product */
SELECT 
    product_name,
    SUM(quantity * price) AS product_revenue
FROM kinesis_firehose_destination_g1
GROUP BY product_name
ORDER BY product_revenue DESC;


/* 6. Highest revenue product */
SELECT *
FROM (
    SELECT 
        product_name,
        SUM(quantity * price) AS revenue,
        RANK() OVER (ORDER BY SUM(quantity * price) DESC) AS rnk
    FROM kinesis_firehose_destination_g1
    GROUP BY product_name
) t
WHERE rnk = 1;


/* 7. Average order value */
SELECT 
    AVG(quantity * price) AS avg_order_value
FROM kinesis_firehose_destination_g1;


/* 8. Top 3 expensive orders */
SELECT *
FROM (
    SELECT 
        orderid,
        product_name,
        quantity * price AS total_amount,
        ROW_NUMBER() OVER (ORDER BY quantity * price DESC) AS rn
    FROM kinesis_firehose_destination_g1
) t
WHERE rn <= 3;


/* 9. Count number of orders per product */
SELECT 
    product_name,
    COUNT(*) AS total_orders
FROM kinesis_firehose_destination_g1
GROUP BY product_name;


/* 10. Find orders where quantity > 3 */
SELECT *
FROM kinesis_firehose_destination_g1
WHERE quantity > 3;


/* 11. Find total number of distinct products */
SELECT COUNT(DISTINCT product_name) AS unique_products
FROM kinesis_firehose_destination_g1;


/* 12. Find total number of orders */
SELECT COUNT(DISTINCT orderid) AS total_orders
FROM kinesis_firehose_destination_g1;


/* 13. Find product with highest single order quantity */
SELECT *
FROM kinesis_firehose_destination_g1
ORDER BY quantity DESC
LIMIT 1;


/* 14. Find minimum price per product */
SELECT product_name, MIN(price) AS min_price
FROM kinesis_firehose_destination_g1
GROUP BY product_name;


/* 15. Find maximum quantity per product */
SELECT product_name, MAX(quantity) AS max_quantity
FROM kinesis_firehose_destination_g1
GROUP BY product_name;


/* 16. Find products where average quantity > 3 */
SELECT product_name, AVG(quantity) AS avg_qty
FROM kinesis_firehose_destination_g1
GROUP BY product_name
HAVING AVG(quantity) > 3;


/* 17. Calculate price variance per product */
SELECT product_name, VARIANCE(price) AS price_variance
FROM kinesis_firehose_destination_g1
GROUP BY product_name;

/* 18. Find median price in Athena */

SELECT 
    approx_percentile(price, 0.5) AS median_price
FROM kinesis_firehose_destination_g1;




/* 19. Running total revenue ordered by orderid */
SELECT 
    orderid,
    SUM(quantity * price)
    OVER (ORDER BY orderid ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    AS running_revenue
FROM kinesis_firehose_destination_g1;


/* 20. Percentage contribution of each product to total revenue */
SELECT 
    product_name,
    SUM(quantity * price) AS revenue,
    ROUND(
        100.0 * SUM(quantity * price) /
        SUM(SUM(quantity * price)) OVER (),
        2
    ) AS revenue_percentage
FROM kinesis_firehose_destination_g1
GROUP BY product_name;


/* 21. Find duplicate order IDs */
SELECT orderid, COUNT(*) AS occurrences
FROM kinesis_firehose_destination_g1
GROUP BY orderid
HAVING COUNT(*) > 1;


/* 22. Find second highest price */
SELECT DISTINCT price
FROM kinesis_firehose_destination_g1
ORDER BY price DESC
OFFSET 1 LIMIT 1;


/* 23. Find products with price above overall average price */
SELECT *
FROM kinesis_firehose_destination_g1
WHERE price > (
    SELECT AVG(price)
    FROM kinesis_firehose_destination_g1
);


/* 24. Categorize orders as High, Medium, Low value */
SELECT 
    orderid,
    quantity * price AS total_amount,
    CASE 
        WHEN quantity * price > 1000 THEN 'High'
        WHEN quantity * price BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Low'
    END AS order_category
FROM kinesis_firehose_destination_g1;


/* 25. Find product with most number of transactions */
SELECT product_name, COUNT(*) AS txn_count
FROM kinesis_firehose_destination_g1
GROUP BY product_name
ORDER BY txn_count DESC
LIMIT 1;


/* 26. Calculate standard deviation of price */
SELECT STDDEV(price) AS price_std_dev
FROM kinesis_firehose_destination_g1;


/* 27. Find cumulative quantity per product */
SELECT 
    product_name,
    orderid,
    SUM(quantity) OVER (
        PARTITION BY product_name
        ORDER BY orderid
    ) AS cumulative_quantity
FROM kinesis_firehose_destination_g1;


/* 28. Find gap between highest and lowest price */
SELECT 
    MAX(price) - MIN(price) AS price_gap
FROM kinesis_firehose_destination_g1;

/* 29. Identify products contributing more than 30 percent of total revenue */

WITH product_revenue AS (
    SELECT 
        product_name,
        SUM(quantity * price) AS revenue
    FROM kinesis_firehose_destination_g1
    GROUP BY product_name
),
total_revenue AS (
    SELECT SUM(quantity * price) AS total_rev
    FROM kinesis_firehose_destination_g1
)

SELECT 
    p.product_name,
    p.revenue,
    ROUND(p.revenue * 100.0 / t.total_rev, 2) AS pct
FROM product_revenue p
CROSS JOIN total_revenue t
ORDER BY pct DESC;



/* 30. Find top 2 products by average order value */
SELECT *
FROM (
    SELECT 
        product_name,
        AVG(quantity * price) AS avg_order_value,
        ROW_NUMBER() OVER (ORDER BY AVG(quantity * price) DESC) AS rn
    FROM kinesis_firehose_destination_g1
    GROUP BY product_name
) t
WHERE rn <= 2;