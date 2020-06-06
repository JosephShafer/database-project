SELECT customer.customer_id, customer.fname, customer.lname, customer.username
FROM customer
INNER JOIN product_order
ON product_order.customer_id = customer.customer_id
WHERE NOT EXISTS
    (
        SELECT product_order.order_time
        WHERE 
        product_order.order_time > now() - interval '6 months'
    )
AND
customer.username IS NOT NULL
GROUP BY customer.customer_id, customer.fname, customer.lname, customer.username
ORDER BY customer.customer_id
;
