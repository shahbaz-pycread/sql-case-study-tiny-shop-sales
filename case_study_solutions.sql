--1) Which product has the highest price? Only return a single row.

SELECT 
  product_name, 
  price
FROM products
ORDER BY price DESC
LIMIT 1;

--2) Which customer has made the most orders?

SELECT 
  customers.first_name, 
  customers.last_name, 
  COUNT(orders.order_id) AS order_count
FROM customers
JOIN orders ON customers.customer_id = orders.customer_id
GROUP BY customers.first_name, customers.last_name
ORDER BY order_count DESC
LIMIT 1;

--3) What’s the total revenue per product?

SELECT 
   pro.product_name, 
   SUM(pro.price * items.quantity) as total_revenue
FROM products pro
JOIN order_items items ON pro.product_id = items.product_id
GROUP BY pro.product_name
ORDER BY total_revenue DESC;

--4) Find the day with the highest revenue.

SELECT  
  ord.order_date,  
  SUM(pro.price * items.quantity) total_revenue
FROM products pro
JOIN order_items items ON pro.product_id = items.product_id
JOIN orders ord ON items.order_id = ord.order_id
GROUP BY ord.order_date
ORDER BY total_revenue DESC
LIMIT 1;

--5) Find the first order (by date) for each customer.

SELECT  
  cus.first_name, 
  cus.last_name, 
  min(ord.order_date) first_order
FROM customers cus
JOIN orders ord ON cus.customer_id = ord.customer_id
GROUP  BY cus.first_name, cus.last_name, ord.order_date
ORDER BY first_order;

--6) Find the top 3 customers who have ordered the most distinct products

SELECT 
   cust.first_name, 
   cust.last_name, 
   COUNT(DISTINCT product_name) unique_products
FROM customers cust
JOIN orders ord ON cust.customer_id = ord.customer_id
JOIN order_items items ON ord.order_id = items.order_id
JOIN products prod ON items.product_id = prod.product_id
GROUP BY cust.first_name, cust.last_name
ORDER BY unique_products DESC
LIMIT 3;

--7) Which product has been bought the least in terms of quantity?

SELECT  
   prod.product_id, 
   SUM(items.quantity) Total_Quantities
FROM order_items items
JOIN products prod ON items.product_id = prod.product_id
GROUP BY prod.product_id
ORDER BY Total_Quantities
LIMIT 3;

--8) What is the median order total?

WITH order_totals AS (
    SELECT 
       ord.order_id, 
       SUM(prod.price * items.quantity) AS total
    FROM orders ord
    JOIN order_items items ON ord.order_id = items.order_id
    JOIN products prod ON items.product_id = prod.product_id
    GROUP BY ord.order_id
)
SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total) AS median_order_total
FROM order_totals;

--9) For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.

 SELECT 
   order_id,
      CASE
         WHEN revenue > 300 THEN 'Expensive'
         WHEN revenue > 100 THEN 'Affordable'
         ELSE 'Cheap'
      END AS price_bracket
      FROM (
       SELECT 
         order_id, 
         sum((price * quantity)) as revenue
      FROM products prod
LEFT JOIN order_items items ON prod.product_id = items.product_id
GROUP BY order_id
) as total_order;

--10) Find customers who have ordered the product with the highest price.

SELECT 
   customer_id, 
   cust.first_name, 
   cust.last_name
FROM customers cust
LEFT JOIN orders
USING (customer_id)
LEFT JOIN order_items items
USING (order_id)
LEFT JOIN products prod
USING (product_id)
WHERE price = (
 SELECT MAX(price)
 FROM products
);