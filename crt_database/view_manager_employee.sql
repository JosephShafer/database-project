DROP VIEW IF EXISTS view_manager_employee;
CREATE VIEW view_manager_employee AS 
SELECT employee.fname || ' ' || employee.lname AS employee_name, work_history.pay_rate, work_history.job_title
FROM employee
INNER JOIN work_history ON work_history.employee_id = employee.employee_id
;
