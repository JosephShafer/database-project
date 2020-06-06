SELECT product_order.p_order_number, product_order.status_id, order_status.status, payment.payment_id, payment.amount
FROM product_order
INNER JOIN order_status ON product_order.status_id = order_status.status_id
INNER JOIN requires ON product_order.p_order_number = requires.p_order_number
INNER JOIN payment ON requires.payment_id = payment.payment_id
WHERE order_status.status = 'delivered'
AND
payment.amount > 100
;
