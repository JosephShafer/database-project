
-- This page includes work we did to try to solve
-- Phase 3 Queries



-- 1. List customers who have made at least 2 product orders between 1/18/20 and 2/18/20.

-- AGGREGATE FUNCTION WAY
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


-- 2. List customers with accounts on our website that have not made a product order in the past 6 months. DONE 
SELECT customer.customer_id, customer.fname, customer.lname, customer.username, product_order.order_time
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
GROUP BY customer.customer_id, customer.fname, customer.lname, customer.username, product_order.order_time
ORDER BY customer.customer_id
;

-- no time grouped up
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


-- 3. List employees who purchased flower products from every supplier. DONE
-- 11 and 29 have done 1 each, 1 and 2 have ordered from all
-- might be way to do this with division/not exists?
SELECT supply_purchase_order.employee_id, employee.fname, employee.lname
FROM supply_purchase_order 
INNER JOIN supplier ON supply_purchase_order.supply_id = supplier.supply_id
INNER JOIN employee ON supply_purchase_order.employee_id = employee.employee_id
GROUP BY supply_purchase_order.employee_id, employee.fname, employee.lname
HAVING COUNT(DISTINCT(supply_purchase_order.supply_id)) = (
    SELECT COUNT(*)
    FROM supplier
)
;


-- 4. List product orders with a payment greater than $100 that have been delivered.
SELECT product_order.p_order_number, product_order.status_id, order_status.status, payment.payment_id, payment.amount
FROM product_order
INNER JOIN order_status ON product_order.status_id = order_status.status_id
INNER JOIN requires ON product_order.p_order_number = requires.p_order_number
INNER JOIN payment ON requires.payment_id = payment.payment_id
WHERE order_status.status = 'delivered'
AND
payment.amount > 100
;


-- 5. List current employees who have processed all John Doe’s purchases. 
-- gets result but not right query
SELECT employee.employee_id, employee.fname, employee.lname, work_history.employee_id, product_order.p_order_number, customer.customer_id
FROM employee
INNER JOIN work_history ON work_history.employee_id = employee.employee_id
INNER JOIN product_order ON employee.employee_id = product_order.employee_id
INNER JOIN customer ON  customer.customer_id = product_order.customer_id
WHERE customer.fname = 'John' and customer.lname = 'Doe'
AND work_history.end_date IS NULL
ORDER BY employee.employee_id;
;

-- THIS ONE CORRECT
SELECT employee.employee_id, employee.fname, employee.lname
FROM employee
INNER JOIN work_history ON work_history.employee_id = employee.employee_id
INNER JOIN product_order ON employee.employee_id = product_order.employee_id
INNER JOIN customer ON  customer.customer_id = product_order.customer_id
WHERE customer.fname = 'John' and customer.lname = 'Doe'
AND work_history.end_date IS NULL
GROUP BY employee.employee_id, employee.fname, employee.lname
;



-- 6. List the package(s) that has the second least expensive product order.


CREATE TEMPORARY TABLE total_cost_of_orders (
    ID INT,
    total_price decimal(12,2)
);

INSERT INTO total_cost_of_orders 
select p_order_number, SUM(contains.point_of_sale_price)
from contains
GROUP BY p_order_number
ORDER BY SUM(contains.point_of_sale_price);

-- DONE

CREATE TEMPORARY TABLE total_cost_of_orders 
    AS (
        select p_order_number ID, SUM(contains.point_of_sale_price) total_price
        from contains
        GROUP BY p_order_number
        ORDER BY SUM(contains.point_of_sale_price)
    ) 
;

DELETE FROM total_cost_of_orders
WHERE total_price =
    (
        SELECT 
            MIN(total_cost_of_orders.total_price)
        FROM
            total_cost_of_orders
    )
;
-- Redo, issue with nulls
SELECT package.package_id, total_cost_of_orders.ID, total_cost_of_orders.total_price, product_order.p_order_number
FROM package
INNER JOIN product_order ON product_order.p_order_number = package.p_order_number
FULL OUTER JOIN total_cost_of_orders ON total_cost_of_orders.ID = product_order.p_order_number
WHERE total_cost_of_orders.total_price = 
    (
        SELECT 
            MIN(total_cost_of_orders.total_price)
        FROM
            total_cost_of_orders
    )
AND package.package_id IS NOT NULL
;

--

CREATE TEMPORARY TABLE total_cost_of_orders 
    AS (
        select p_order_number ID, SUM(contains.point_of_sale_price) total_price
        from contains
        GROUP BY p_order_number
        ORDER BY SUM(contains.point_of_sale_price)
    ) 
DELETE FROM total_cost_of_orders
WHERE total_price =
    (
        SELECT 
            MIN(total_cost_of_orders.total_price)
        FROM
            total_cost_of_orders
    )
;



-- 7. List recipients who have never received red roses.
-- I think I might be able to do a temp table instead
-- DO get red roses
SELECT contains.p_order_number, contains.product_id, flower_product.color, flower_product.product_name,
recipient.recipient_id, recipient.fname, recipient.lname
FROM contains
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
INNER JOIN product_order ON contains.p_order_number = product_order.p_order_number
INNER JOIN package ON product_order.p_order_number = package.p_order_number
INNER JOIN recipient ON package.package_id = recipient.package_id
WHERE 
product_order.p_order_number = package.p_order_number
AND
flower_product.product_name = 'Rose'
ORDER BY contains.p_order_number
;

-- THIS ONE WORKS I THINK
SELECT recipient.recipient_id, recipient.fname, recipient.lname
FROM contains
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
INNER JOIN product_order ON contains.p_order_number = product_order.p_order_number
INNER JOIN package ON product_order.p_order_number = package.p_order_number
INNER JOIN recipient ON package.package_id = recipient.package_id
WHERE 
product_order.p_order_number = package.p_order_number
EXCEPT
SELECT recipient.recipient_id, recipient.fname, recipient.lname
FROM contains
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
INNER JOIN product_order ON contains.p_order_number = product_order.p_order_number
INNER JOIN package ON product_order.p_order_number = package.p_order_number
INNER JOIN recipient ON package.package_id = recipient.package_id
WHERE 
product_order.p_order_number = package.p_order_number
and flower_product.product_name = 'Rose'
ORDER BY recipient_id
;


-- 8. List the suppliers that have no supply purchase order with more than 1 flower product.
--  list suppliers that have only ever received orders to fill 1 flower product
--SELECT refills.supply_purchase_id, supply_purchase_order.supply_purchase_id, supplier.supply_id, flower_product.product_id





SELECT Count(flower_product.product_id)
from flower_product
;



SELECT supply_purchase_order.supply_purchase_id, COUNT(supplier.supply_id), refills.supply_purchase_id, refills.product_id, 
FROM supply_purchase_order
INNER JOIN supplier ON supply_purchase_order.supply_id = supplier.supply_id
INNER JOIN refills ON refills.supply_purchase_id = supply_purchase_order.supply_purchase_id
GROUP BY supply_purchase_order.supply_purchase_id, supplier.supply_id, refills.supply_purchase_id, refills.product_id
ORDER BY supplier.supply_id
HAVING COUNT(supplier.supply_id) <= 1
;
-- This one
SELECT supplier.vendor_name, supplier.supply_id, COUNT(*) as num_products_filled
FROM supply_purchase_order
INNER JOIN supplier ON supply_purchase_order.supply_id = supplier.supply_id
INNER JOIN refills ON refills.supply_purchase_id = supply_purchase_order.supply_purchase_id
GROUP BY supplier.vendor_name, supplier.supply_id
HAVING  COUNT(*) <= 1
ORDER BY supplier.supply_id
;
--



-- 9. List customers who have purchased all flower products.

-- THIS ONE
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
--


SELECT product_order.p_order_number
FROM contains
INNER JOIN product_order ON product_order.p_order_number = contains.p_order_number
INNER JOIN flower_product ON flower_product.product_id = contains.product_id
GROUP BY product_order.p_order_number
HAVING COUNT(DISTINCT(contains.product_id)) = (
    SELECT COUNT(*)
    FROM flower_product
)
;




-- 10. List the cheapest package delivered by John Doe.

SELECT package.package_id, product_order.p_order_number


-- SELECT contains.p_order_number, SUM(contains.point_of_sale_price)
-- FROM contains
-- INNER JOIN product_order ON product_order.p_order_number = contains.p_order_number
-- INNER JOIN employee ON employee.employee_id = product_order.employee_id
-- INNER JOIN package ON package.p_order_number = product_order.p_order_number
-- WHERE
-- employee.fname = 'John' AND employee.lname = 'Doe'
-- AND
-- package.employee_id = employee.employee_id
-- GROUP BY contains.p_order_number
-- ORDER BY SUM(contains.point_of_sale_price) asc
-- LIMIT 1
-- ;

-- This one
SELECT employee.fname || ' ' || employee.lname as empname, contains.p_order_number, SUM(contains.point_of_sale_price)
FROM contains
INNER JOIN product_order ON product_order.p_order_number = contains.p_order_number
INNER JOIN package ON package.p_order_number = product_order.p_order_number
INNER JOIN employee ON employee.employee_id = package.employee_id
WHERE
employee.fname = 'John' AND employee.lname = 'Doe'
AND
package.employee_id = employee.employee_id
GROUP BY empname, contains.p_order_number
ORDER BY SUM(contains.point_of_sale_price) asc
LIMIT 1
;


-- SELECT employee.fname, employee.lname, package.employee_id, contains.p_order_number, SUM(contains.point_of_sale_price)
-- FROM contains
-- INNER JOIN product_order ON product_order.p_order_number = contains.p_order_number
-- INNER JOIN package ON package.p_order_number = product_order.p_order_number
-- INNER JOIN employee ON employee.employee_id = package.employee_id

-- GROUP BY package.employee_id, employee.fname, employee.lname, contains.p_order_number
-- ORDER BY SUM(contains.point_of_sale_price) asc
-- ;





SELECT package.package_id, total_cost_of_orders.ID, total_cost_of_orders.total_price, product_order.p_order_number
FROM package
INNER JOIN product_order ON product_order.p_order_number = package.p_order_number
FULL OUTER JOIN total_cost_of_orders ON total_cost_of_orders.ID = product_order.p_order_number
WHERE total_cost_of_orders.total_price = 
    (
        SELECT 
            MIN(total_cost_of_orders.total_price)
        FROM
            total_cost_of_orders
    )
;