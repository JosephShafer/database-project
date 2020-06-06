-- DROP VIEW IF EXISTS view_manager_revenue;
-- CREATE VIEW view_manager_revenue AS
-- select incoming_payment.incoming_payment_id, outgoing_payment.outgoing_payment_id, payment.payment_time::date Date_Paid, payment.amount
-- FROM incoming_payment
-- RIGHT JOIN payment ON incoming_payment.incoming_payment_id = payment.incoming_payment_id
-- LEFT JOIN outgoing_payment ON outgoing_payment.outgoing_payment_id = payment.outgoing_payment_id
-- ;

DROP VIEW IF EXISTS view_positive_revenue;
CREATE VIEW view_positive_revenue AS
SELECT customer.fname || ' ' || customer.lname as customer_name, to_char(MAX(payment.payment_time::date), 'MM-DD-YYYY') last_bought, SUM(payment.amount) revenue
FROM incoming_payment
INNER JOIN payment ON incoming_payment.incoming_payment_id = payment.incoming_payment_id
INNER JOIN requires ON requires.incoming_payment_id = incoming_payment.incoming_payment_id
INNER JOIN product_order ON requires.p_order_number = product_order.p_order_number
LEFT JOIN customer ON product_order.customer_id = customer.customer_id
GROUP BY customer_name
ORDER BY customer_name
;

DROP VIEW IF EXISTS view_expenditure;
CREATE VIEW view_expenditure AS
SELECT supplier.vendor_name, to_char(MAX(payment.payment_time::date), 'MM-DD-YYYY') last_paid_to, SUM(payment.amount) expenditure
FROM outgoing_payment
INNER JOIN payment ON outgoing_payment.outgoing_payment_id = payment.outgoing_payment_id
INNER JOIN needs ON needs.outgoing_payment_id = outgoing_payment.outgoing_payment_id
INNER JOIN supply_purchase_order ON supply_purchase_order.supply_purchase_id = needs.supply_purchase_id
LEFT JOIN supplier ON supply_purchase_order.supply_id = supplier.supply_id
GROUP BY supplier.vendor_name
;


-- SELECT SUM(revenue) - (
--     select SUM(expenditure)
--     FROM view_expenditure
-- ) AS total
-- FROM view_positive_revenue
-- ;




-- CREATE VIEW view_manager_revenue AS
-- SELECT customer.customer_id, customer.fname pay_from, outgoing_payment.payment_id out_pay, incoming_payment.payment_id inc_pay, amount
-- FROM payment
-- LEFT JOIN outgoing_payment ON payment.payment_id = outgoing_payment.payment_id
-- LEFT JOIN incoming_payment ON payment.payment_id = incoming_payment.payment_id
-- RIGHT JOIN requires ON payment.payment_id = requires.payment_id
-- RIGHT JOIN product_order ON product_order.p_order_number = requires.p_order_number
-- RIGHT JOIN customer ON product_order.customer_id = customer.customer_id
-- WHERE
--  outgoing_payment.payment_id IS NOT NULL
--  OR
--  incoming_payment.payment_id IS NOT NULL
-- ORDER BY customer.customer_id;


-- SELECT outgoing_payment.payment_id outgoing_payment, incoming_payment.payment_id incoming_payment, amount
-- FROM outgoing_payment
-- FULL OUTER JOIN incoming_payment on incoming_payment.payment_id = outgoing_payment.payment_id
-- FULL OUTER JOIN payment ON payment.payment_id = incoming_payment.payment_id
-- WHERE outgoing_payment.payment_id IS NULL OR incoming_payment.payment_id IS NULL;