SELECT customer.customer_id, COUNT(*) as num_orders
FROM customer
INNER JOIN product_order
ON product_order.customer_id = customer.customer_id
WHERE 
(order_time >= timestamp '2020-01-18 00:00:00'
AND order_time <= timestamp '2020-02-18 00:00:00')
GROUP BY customer.customer_id
HAVING COUNT(*) >= 2
;
