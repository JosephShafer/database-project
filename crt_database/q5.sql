SELECT employee.employee_id, employee.fname, employee.lname
FROM employee
INNER JOIN work_history ON work_history.employee_id = employee.employee_id
INNER JOIN product_order ON employee.employee_id = product_order.employee_id
INNER JOIN customer ON  customer.customer_id = product_order.customer_id
WHERE customer.fname = 'John' and customer.lname = 'Doe'
AND work_history.end_date IS NULL
GROUP BY employee.employee_id, employee.fname, employee.lname
;