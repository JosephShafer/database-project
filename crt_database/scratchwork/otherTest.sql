select employee.fname, work_shift.begin_time, work_shift.end_time
from employee
inner join work_shift on work_shift.employee_id = employee.employee_id
;

select incoming_payment.incoming_payment_id, outgoing_payment.outgoing_payment_id, payment.amount
FROM incoming_payment
RIGHT JOIN payment ON incoming_payment.incoming_payment_id = payment.incoming_payment_id
LEFT JOIN outgoing_payment ON outgoing_payment.outgoing_payment_id = payment.outgoing_payment_id
ORDER BY payment.amount
;

SELECT *
FROM incoming_payment;