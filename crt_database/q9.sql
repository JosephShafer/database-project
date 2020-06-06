SELECT customer.customer_id, customer.fname, customer.lname
FROM customer
INNER JOIN product_order ON customer.customer_id = product_order.customer_id
INNER JOIN contains ON product_order.p_order_number = contains.p_order_number
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
GROUP BY customer.customer_id, customer.fname, customer.lname
HAVING COUNT(DISTINCT(contains.product_id)) = (
    SELECT COUNT(*)
    FROM flower_product
)
;