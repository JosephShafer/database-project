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