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