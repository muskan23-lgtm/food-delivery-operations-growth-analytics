-- Food Delivery Operations & Growth Analytics
-- Dialect: PostgreSQL (adapt DATE_TRUNC / EXTRACT if using MySQL)

-- 1. Total orders and delivered orders
SELECT COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE order_status = 'Delivered') AS delivered_orders
FROM orders;

-- 2. Revenue from delivered orders (gross order value)
SELECT ROUND(SUM(order_amount), 2) AS delivered_gmv
FROM orders
WHERE order_status = 'Delivered';

-- 3. Average order value (delivered orders)
SELECT ROUND(AVG(order_amount), 2) AS average_order_value
FROM orders
WHERE order_status = 'Delivered';

-- 4. Monthly order and revenue trend
SELECT DATE_TRUNC('month', order_datetime::timestamp) AS order_month,
       COUNT(*) AS orders,
       ROUND(SUM(CASE WHEN order_status='Delivered' THEN order_amount ELSE 0 END),2) AS delivered_gmv
FROM orders
GROUP BY 1 ORDER BY 1;

-- 5. Cancellation rate
SELECT ROUND(100.0 * COUNT(*) FILTER (WHERE order_status='Cancelled') / COUNT(*), 2) AS cancellation_pct
FROM orders;

-- 6. Top 10 restaurants by delivered GMV
SELECT r.restaurant_name, r.city, ROUND(SUM(o.order_amount),2) AS delivered_gmv
FROM orders o JOIN restaurants r USING (restaurant_id)
WHERE o.order_status='Delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.city
ORDER BY delivered_gmv DESC LIMIT 10;

-- 7. Average delivery time by city
SELECT r.city, ROUND(AVG(d.delivery_minutes),1) AS avg_delivery_minutes
FROM deliveries d
JOIN orders o USING (order_id)
JOIN restaurants r USING (restaurant_id)
GROUP BY r.city ORDER BY avg_delivery_minutes;

-- 8. Repeat customers (more than one delivered order)
SELECT customer_id, COUNT(*) AS delivered_orders
FROM orders WHERE order_status='Delivered'
GROUP BY customer_id HAVING COUNT(*) > 1
ORDER BY delivered_orders DESC;

-- 9. Peak ordering hours
SELECT EXTRACT(HOUR FROM order_datetime::timestamp) AS order_hour,
       COUNT(*) AS order_count
FROM orders GROUP BY 1 ORDER BY order_count DESC;

-- 10. Restaurant cancellation rate
SELECT r.restaurant_name,
       COUNT(*) AS total_orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE o.order_status='Cancelled') / COUNT(*),2) AS cancellation_pct
FROM orders o JOIN restaurants r USING (restaurant_id)
GROUP BY r.restaurant_id, r.restaurant_name
HAVING COUNT(*) >= 20
ORDER BY cancellation_pct DESC;

-- 11. Customer order value and segmentation
SELECT customer_id, COUNT(*) AS orders,
       ROUND(SUM(order_amount),2) AS total_order_value,
       CASE WHEN COUNT(*) >= 10 THEN 'High frequency'
            WHEN COUNT(*) >= 4 THEN 'Medium frequency'
            ELSE 'Low frequency' END AS customer_segment
FROM orders WHERE order_status='Delivered'
GROUP BY customer_id;

-- 12. Delivery delay flag (threshold: 45 minutes; adjust as a business rule)
SELECT order_id, delivery_minutes,
       CASE WHEN delivery_minutes > 45 THEN 'Delayed' ELSE 'On time' END AS delivery_flag
FROM deliveries;

-- 13. Cancellation reasons
SELECT cr.cancellation_reason, COUNT(*) AS cancelled_orders
FROM cancellation_reasons cr
GROUP BY cr.cancellation_reason ORDER BY cancelled_orders DESC;

-- 14. Revenue by city
SELECT r.city, ROUND(SUM(o.order_amount),2) AS delivered_gmv
FROM orders o JOIN restaurants r USING (restaurant_id)
WHERE o.order_status='Delivered'
GROUP BY r.city ORDER BY delivered_gmv DESC;

-- 15. Month-over-month GMV growth
WITH monthly AS (
  SELECT DATE_TRUNC('month', order_datetime::timestamp) AS month,
         SUM(CASE WHEN order_status='Delivered' THEN order_amount ELSE 0 END) AS gmv
  FROM orders GROUP BY 1
)
SELECT month, ROUND(gmv,2) AS gmv,
       ROUND(100.0*(gmv-LAG(gmv) OVER (ORDER BY month)) /
             NULLIF(LAG(gmv) OVER (ORDER BY month),0),2) AS mom_growth_pct
FROM monthly ORDER BY month;
