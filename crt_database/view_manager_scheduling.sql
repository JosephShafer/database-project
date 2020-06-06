CREATE VIEW view_manager_scheduling AS
SELECT employee.employee_id, employee.fname || ' ' || employee.lname AS employee_name,
work_history.pay_rate, work_history.job_title, work_shift.shift_date as day,
work_shift.begin_time as shift_start, work_shift.end_time as shift_end
FROM employee
INNER JOIN work_history ON work_history.employee_id = employee.employee_id
INNER JOIN work_shift ON work_shift.employee_id = employee.employee_id
WHERE work_history.end_date IS NULL
order by employee_id, shift_start
;

DROP VIEW IF EXISTS view_number_employees_working;
CREATE VIEW view_number_employees_working AS 
SELECT work_history.job_title, COUNT(work_history.job_title) count_of_job_type, work_shift.shift_date as day
FROM employee
INNER JOIN work_history ON work_history.employee_id = employee.employee_id
INNER JOIN work_shift ON work_shift.employee_id = employee.employee_id
GROUP BY work_history.job_title, work_shift.shift_date
ORDER BY work_shift.shift_date
;
